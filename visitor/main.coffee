# 本当はモデルとビューを分けるんだろうけど複雑になって目標を見失うので
# あえて分けません。本当は分けるんです。本当は。

textNodeTemplate = """
  <div class="node">
      <div class="content text">テスト</div>
  </div>
"""

class BasicNode
  accept: (visitor, options)->
    visitor.visit(@, options)

  # 全ての派生が持つと明瞭ならインターフェースで良い
  setBackgroundColor: (color)->
    @$el.css('backgroundColor', color)

class TextLeafNode extends BasicNode
  setup: (@$parent)->
    @$el = $(textNodeTemplate).appendTo(@$parent)
    editor = new NodeEditor(@)
    editor.setup()

  setText: (text)->
    $textContent = @$el.find('.text.content')
    $textContent.text(text)


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

  accept: (visitor, options)->
    @forEach (node)->
      visitor.visit(node, options)

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

class BasicVisitor
  visit: (obj, options)->
    #ここを型（オーバーロード）で解決出来る方が良いけど本質ではない
    @['visit' + obj.constructor.name](obj, options)

  visitCompositeNode: (compositeNode, options)->
    compositeNode.forEach (node)=>
      @visit(node, options)


class TextEditVisitor extends BasicVisitor
  visitTextLeafNode: (textLeafNode, options)->
    textLeafNode.setText(options.text)

class NodeEditor
  constructor: (@node)->
    @visitors =
      textEdit: new TextEditVisitor()

  setup: ->
    $editor = $(nodeEditorTemplate).appendTo(@node.$el)
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

  node = new CompositeNode()
  node.addNode(new TextLeafNode())
  node.addNode(cnode)
  node.addNode(new TextLeafNode())
  node.setup($('body'))
