# 本当はモデルとビューを分けるんだろうけど複雑になって目標を見失うので
# あえて分けません。本当は分けるんです。本当は。

class BasicNode
  accept: (visitor, options, level)->
    visitor.visit(@, options, level)

  # 全ての派生が持つと明瞭ならインターフェースで良い
  setBackgroundColor: (color)->
    @backgroundColor = color
    @$el.css('backgroundColor', color)

  getBackgroundColor: ()->
    @backgroundColor

compositeNodeTemplate = """
  <div class="node">
      <ul class="content composite"></ul>
  </div>
"""

class CompositeNode extends BasicNode
  constructor: ()->
    @nodes = []

  forEach: (callback)->
    @nodes.forEach(callback)

  accept: (visitor, options, level)->
    my_level =
      value: if level?.value then level.value + 1 else 1

    @forEach (node)->
      node.accept(visitor, options, my_level)


  setBackgroundColor: (color)->
    super(color)
    @forEach (node)->
      node.setBackgroundColor(color)

  setup: (@$parent)->
    @$el = $(compositeNodeTemplate).appendTo(@$parent)
    @forEach (node)=>
      $li = $('<li></li>').appendTo(@$el.find('>ul'))
      node.setup($li)

    editor = new NodeEditor(@)
    editor.setup()

  addNode: (node)->
    @nodes.push(node)


textNodeTemplate = """
  <div class="node">
      <div class="content text">テスト</div>
  </div>
"""

class TextLeafNode extends BasicNode
  setup: (@$parent)->
    @$el = $(textNodeTemplate).appendTo(@$parent)
    editor = new NodeEditor(@)
    editor.setup()

  setText: (text)->
    $textContent = @$el.find('.text.content')
    $textContent.text(text)

  getText: ->
    $textContent = @$el.find('.text.content')
    $textContent.text()

hrNodeTemplate = """
  <div class="node">
      <hr class="content hr">
  </div>
"""

class HrLeafNode extends BasicNode
  setup: (@$parent)->
    @$el = $(hrNodeTemplate).appendTo(@$parent)


class BasicVisitor
  visit: (obj, options, level)->
    #ここを型（オーバーロード）で解決出来る方が良いけど本質ではない
    method  = @['visit' + obj.constructor.name]
    if method
      method.call(@, obj, options, level)
    else
      unmatchedNode(obj, options, level)

  visitCompositeNode: (compositeNode, options, level)->
    compositeNode.forEach (node)=>
      @visit(node, options, level)

  unmachedNode: (obj, options, level)->
    #nop


class TextEditVisitor extends BasicVisitor
  visitTextLeafNode: (textLeafNode, options)->
    textLeafNode.setText(options.text)

  visitHrLeafNode: (hrLeafNode, options)->
    #nop

class HTMLExportingVisitor extends BasicVisitor
  constructor: ->
    @content = ''

  visitTextLeafNode: (textLeafNode, options)->
    bg = textLeafNode.getBackgroundColor()
    start = if bg then "<div style=\"background-color: #{bg}\">" else '<div>'
    @content += start + textLeafNode.getText() + "</div>\n";

  visitHrLeafNode: (hrLeafNode, options)->
    @content += '<hr>\n'

class TextExportingVisitor extends BasicVisitor
  constructor: ->
    @content = ''

  visitTextLeafNode: (textLeafNode, options, level)->
    @content += @getIndent(level) + textLeafNode.getText() + "\n";

  visitHrLeafNode: (hrLeafNode, options, level)->
    @content += @getIndent(level) + '--- \n'

  getIndent:(level)->
    indent = ''
    for i in [1..level.value]
      indent += '>'
    indent

class NodeEditor
  constructor: (@node, @tpl = nodeEditorTemplate)->
    @visitors =
      textEdit: new TextEditVisitor()

  setup: ->
    $editor = $(@tpl).appendTo(@node.$el)
    $editor.find('.changeText').click ()=>
      $text = $editor.find('[name=text]')
      @node.accept @visitors.textEdit, text:$text.val()

    $editor.find('.red').click ()=>
      @node.setBackgroundColor('red')

    $editor.find('.blue').click ()=>
      @node.setBackgroundColor('blue')

nodeEditorTemplate = """
   <div class="editor">
      <input name="text" type="text" value="aaaa">
      <button class="changeText">テキストの変更</button>
      <button class="red">赤</button>
      <button class="blue">青</button>
  </div>
"""

$ ()->
  cnode = new CompositeNode()
  cnode.addNode(new TextLeafNode())
  cnode.addNode(new TextLeafNode())
  cnode.addNode(new HrLeafNode())
  cnode.addNode(new TextLeafNode())

  node = new CompositeNode()
  node.addNode(new TextLeafNode())
  node.addNode(cnode)
  node.addNode(new TextLeafNode())
  node.setup($('#nodes'))

  $('#actions .html').click ()->
    htmlExporter = new HTMLExportingVisitor()
    node.accept(htmlExporter, {})
    $('#field').text htmlExporter.content

  $('#actions .text').click ()->
    textExporter = new TextExportingVisitor()
    node.accept(textExporter, {})
    $('#field').text textExporter.content
