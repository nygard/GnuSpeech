#
# Monet makefile for GNUstep
#

include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = MONET

PROJECTVERSION = 1.1
LANGUAGE = English

APPICON = Monet.tiff
LOCAL_RESOURCES = Info.nib Inspector.nib MONET.nib

GLOBAL_RESOURCES = dotInspector.tiff dotMarker.tiff selectionBox.tiff\
                   squareInspector.tiff squareMarker.tiff\
                   triangleInspector.tiff triangleMarker.tiff\
                   DefaultPrototypes

CLASSES = BooleanExpression.m BooleanParser.m BooleanTerminal.m\
          BrowserManager.m CategoryInspector.m CategoryList.m\
          CategoryNode.m DefaultMgr.m DelegateResponder.m Event.m\
          EventList.m EventListView.m FormulaExpression.m\
          FormulaParser.m FormulaTerminal.m Inspector.m\
          IntonationPoint.m IntonationPointInspector.m\
          IntonationScrollView.m IntonationView.m MyController.m\
          NamedList.m NiftyMatrix.m NiftyMatrixCat.m NiftyMatrixCell.m\
          Parameter.m ParameterInspector.m ParameterList.m Phone.m\
          PhoneInspector.m PhoneList.m Point.m PointInspector.m\
          ProtoEquation.m ProtoEquationInspector.m ProtoTemplate.m\
          ProtoTemplateInspector.m PrototypeManager.m Rule.m\
          RuleInspector.m RuleList.m RuleManager.m Slope.m\
          SlopeRatio.m SpecialView.m StringParser.m Symbol.m\
          SymbolInspector.m SymbolList.m Target.m TargetList.m\
          TransitionView.m TRMData.m \
	  MonetList.m

HFILES = BooleanExpression.h BooleanParser.h BooleanTerminal.h\
         BrowserManager.h CategoryInspector.h CategoryList.h\
         CategoryNode.h DefaultMgr.h DelegateResponder.h Event.h\
         EventList.h EventListView.h FormulaExpression.h\
         FormulaParser.h FormulaTerminal.h Inspector.h\
         IntonationPoint.h IntonationPointInspector.h\
         IntonationScrollView.h IntonationView.h MyController.h\
         NamedList.h NiftyMatrix.h NiftyMatrixCat.h NiftyMatrixCell.h\
         Parameter.h ParameterInspector.h ParameterList.h Phone.h\
         PhoneInspector.h PhoneList.h Point.h PointInspector.h\
         ProtoEquation.h ProtoEquationInspector.h ProtoTemplate.h\
         ProtoTemplateInspector.h PrototypeManager.h Rule.h\
         RuleInspector.h RuleList.h RuleManager.h Slope.h SlopeRatio.h\
         SpecialView.h StringParser.h Symbol.h SymbolInspector.h\
         SymbolList.h Target.h TargetList.h TransitionView.h TRMData.h\
         driftGenerator.h \
	  MonetList.h

MFILES = MONET_main.m stringParser.m

CFILES = driftGenerator.c

OTHERSRCS = Makefile.preamble Makefile Makefile.postamble

MONET_C_FILES = $(CFILES)
MONET_OBJC_FILES = $(CLASSES) $(MFILES)
MONET_RESOURCE_FILES = $(GLOBAL_RESOURCES) 
MONET_MAIN_MODEL_FILE=MONET.gmodel

MONET_LANGUAGES = English

MONET_LOCALIZED_RESOURCE_FILES = Info.gmodel Inspector.gmodel MONET.gmodel

#-include Makefile.preamble

include $(GNUSTEP_MAKEFILES)/application.make

#-include Makefile.postamble
