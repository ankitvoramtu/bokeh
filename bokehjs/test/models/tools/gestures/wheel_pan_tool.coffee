_ = require "underscore"
{expect} = require "chai"
utils = require "../../../utils"
sinon = require 'sinon'

{Document} = utils.require("document")
WheelPanTool = utils.require("models/tools/gestures/wheel_pan_tool.coffee").Model
WheelPanToolView = utils.require("models/tools/gestures/wheel_pan_tool.coffee").View
Range1d = utils.require("models/ranges/range1d").Model
Plot = utils.require("models/plots/plot").Model
Toolbar = utils.require("models/tools/toolbar").Model

describe "WheelPanTool", ->

  describe "Model", ->

    it "should create proper tooltip", ->
      x_tool = new WheelPanTool({dimension: 'width'})
      expect(x_tool.tooltip).to.be.equal('Wheel Pan (x-axis)')

      y_tool = new WheelPanTool({dimension: 'height'})
      expect(y_tool.tooltip).to.be.equal('Wheel Pan (y-axis)')

  describe "View", ->

    afterEach ->
      utils.unstub_canvas()

    beforeEach ->
      utils.stub_canvas()

      @plot = new Plot({
         x_range: new Range1d({start: 0, end: 1})
         y_range: new Range1d({start: 0, end: 1})
      })

      document = new Document()
      document.add_root(@plot)

      @plot_canvas_view = new @plot.plot_canvas.default_view({
        model: @plot.plot_canvas
      })

    it "should translate x-range in positive direction", ->
      x_wheel_pan_tool = new WheelPanTool()

      @plot.add_tools(x_wheel_pan_tool)

      wheel_pan_tool_view = new x_wheel_pan_tool.default_view({
        model: x_wheel_pan_tool
        plot_view: @plot_canvas_view
      })

      # negative factors move in positive x-data direction
      wheel_pan_tool_view._update_ranges(-0.5)
      hr = @plot_canvas_view.frame.x_ranges['default']
      # should be translated by -factor units
      expect([hr.start, hr.end]).to.be.deep.equal([0.5, 1.5])
      vr = @plot_canvas_view.frame.y_ranges['default']
      # should be unchanged from initialized value
      expect([vr.start, vr.end]).to.be.deep.equal([0, 1])

    it "should translate y-range in negative direction", ->
      x_wheel_pan_tool = new WheelPanTool({dimension: 'height'})

      @plot.add_tools(x_wheel_pan_tool)

      wheel_pan_tool_view = new x_wheel_pan_tool.default_view({
        model: x_wheel_pan_tool
        plot_view: @plot_canvas_view
      })

      # positive factors move in positive y-data direction
      wheel_pan_tool_view._update_ranges(0.75)
      hr = @plot_canvas_view.frame.x_ranges['default']
      # should be unchanged from initialized value
      expect([hr.start, hr.end]).to.be.deep.equal([0, 1])

      vr = @plot_canvas_view.frame.y_ranges['default']
      # should be translated by -factor units
      expect([vr.start, vr.end]).to.be.deep.equal([0.75, 1.75])
