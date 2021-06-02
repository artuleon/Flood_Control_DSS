from hec.script import *
from hec.script.Constants import TRUE, FALSE
from hec.heclib.dss import *
import java

#  Open the file and get the data
try:  
    dssFile = HecDss.open("C:\DSSTest_Wetland_Opt_11_14_2018\RAS_HMS_Original_project\CypressHMS\Run_1.dss")
    elev = dssFile.get("//WL-420/ELEVATION/01JAN2018/1HOUR/RUN:RUN 1/")
    stora = dssFile.get("//WL-420/STORAGE/01JAN2018/1HOUR/RUN:RUN 1/")
    inflow = dssFile.get("//WL-420/FLOW-COMBINE/01JAN2018/1HOUR/RUN:RUN 1/")
    TotalOutflow = dssFile.get("//WL-420/FLOW/01JAN2018/1HOUR/RUN:RUN 1/")
    OptimRelease = dssFile.get("//WL-420-RELEASE/FLOW/01JAN2018/1HOUR/RUN:RUN 1/")
    Spill = dssFile.get("//WL-420-SPILL-1/FLOW/01JAN2018/1HOUR/RUN:RUN 1/")
except java.lang.Exception, e :
  #  Take care of any missing data or errors
   MessageBox.showError(e.getMessage(), "Error reading data")

#  Initialize the plot and set viewport size in precent
plot = Plot.newPlot("Wetland plots")
layout = Plot.newPlotLayout()
topView = layout.addViewport(10.)
middleView = layout.addViewport(10.)
bottomView = layout.addViewport(70.)

#  Add Data in specific viewports
topView.addCurve("Y1", elev)
middleView.addCurve("Y2", stora)
bottomView.addCurve("Y1", inflow)
bottomView.addCurve("Y1", TotalOutflow)
bottomView.addCurve("Y1", OptimRelease)
bottomView.addCurve("Y1", Spill)

panel = plot.getPlotpanel()
prop = panel.getProperties()
prop.setViewportSpaceSize(0)

#  Break our first rule - actually this creates the plot to change
plot.configurePlotLayout(layout)

panel = plot.getPlotpanel()
prop = panel.getProperties()
prop.setViewportSpaceSize(0)

#  Invert the precip and make pretty
# view0 = plot.getViewport(0)
# yaxis = view0.getAxis("Y1")
# yaxis.setReversed(FALSE)
# precipCurve = plot.getCurve(precip)

# precipCurve.setFillColor("blue")
# precipCurve.setFillType("Above")
# precipCurve.setLineVisible(FALSE)

#  Set the inflow and outflow colors
elevCurve = plot.getCurve(elev)
elevCurve.setLineColor("darkcyan")
elevCurve.setLineWidth(3.)

storaCurve = plot.getCurve(stora)
storaCurve.setLineColor("green")
storaCurve.setLineWidth(3.)

inflowCurve = plot.getCurve(inflow)
inflowCurve.setLineColor("magenta")
inflowCurve.setLineWidth(3.)

outflowCurve = plot.getCurve(TotalOutflow)
outflowCurve.setLineColor("green")
outflowCurve.setLineWidth(3.)

releaseCurve = plot.getCurve(OptimRelease)
releaseCurve.setLineColor("blue")
releaseCurve.setLineWidth(3.)

spillCurve = plot.getCurve(Spill)
spillCurve.setLineColor("red")
spillCurve.setLineWidth(3.)


# Set the label text
label = plot.getLegendLabel(elev)
label.setText( "Water Surface Elevation")
label.setFont("Arial Black")
label.setFontSize(24)

label = plot.getLegendLabel( stora)
label.setText("Wetland Storage")
label.setFont("Arial Black")
label.setFontSize(24)

label = plot.getLegendLabel(inflow)
label.setText("Total Inflow")
label.setFont("Arial Black")
label.setFontSize(24)

label = plot.getLegendLabel(TotalOutflow)
label.setText("Total Outflow")
label.setFont("Arial Black")
label.setFontSize(24)

label = plot.getLegendLabel(OptimRelease)
label.setText("Optimal Release")
label.setFont("Arial Black")
label.setFontSize(24)

label = plot.getLegendLabel(Spill)
label.setText("Spill Over Wetland")
label.setFont("Arial Black")
label.setFontSize(24)


#  Set the plot title
plot.setPlotTitleText("Wetland WL-420")
tit = plot.getPlotTitle()
tit.setFont("Arial Black")
tit.setFontSize(18)
plot.setPlotTitleVisible(TRUE)

plot.setSize(1500,1200) 
plot.showPlot()



#  Now that it is complete, save to a png and close it
plot.saveToJpeg("C:\DSSTest_Wetland_Opt_11_14_2018\Optimal_results\WL-850", 100)
plot.close()
