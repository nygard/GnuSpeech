//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

// Archiving
#import <GnuSpeech/GSXMLFunctions.h>
#import <GnuSpeech/MXMLArrayDelegate.h>
#import <GnuSpeech/MXMLDictionaryDelegate.h>
#import <GnuSpeech/MXMLIgnoreTreeDelegate.h>
#import <GnuSpeech/MXMLParser.h>
#import <GnuSpeech/MXMLPCDataDelegate.h>
#import <GnuSpeech/MXMLReferenceArrayDelegate.h>
#import <GnuSpeech/MXMLReferenceDictionaryDelegate.h>
#import <GnuSpeech/MXMLStringArrayDelegate.h>

// Extensions
#import <GnuSpeech/NSArray-Extensions.h>
#import <GnuSpeech/NSCharacterSet-Extensions.h>
#import <GnuSpeech/NSFileManager-Extensions.h>
#import <GnuSpeech/NSObject-Extensions.h>
#import <GnuSpeech/NSScanner-Extensions.h>
#import <GnuSpeech/NSString-Extensions.h>

// MonetModel
#import <GnuSpeech/Event.h>
#import <GnuSpeech/EventList.h>
#import <GnuSpeech/MDocument.h>
#import <GnuSpeech/MMCategory.h>
#import <GnuSpeech/MMDriftGenerator.h>
#import <GnuSpeech/MMEquation.h>
#import <GnuSpeech/MMGroup.h>
#import <GnuSpeech/MMIntonationPoint.h>
#import <GnuSpeech/MMNamedObject.h>
#import <GnuSpeech/MMObject.h>
#import <GnuSpeech/MModel.h>
#import <GnuSpeech/MMParameter.h>
#import <GnuSpeech/MMPoint.h>
#import <GnuSpeech/MMPosture.h>
#import <GnuSpeech/MMPostureRewriter.h>
#import <GnuSpeech/MMRule.h>
#import <GnuSpeech/MMSlope.h>
#import <GnuSpeech/MMSlopeRatio.h>
#import <GnuSpeech/MMSymbol.h>
#import <GnuSpeech/MMSynthesisParameters.h>
#import <GnuSpeech/MMTarget.h>
#import <GnuSpeech/MMTextToPhone.h>
#import <GnuSpeech/MMTransition.h>
#import <GnuSpeech/MonetDefaults.h>

// Parsers
#import <GnuSpeech/GSParser.h>
#import <GnuSpeech/MMBooleanExpression.h>
#import <GnuSpeech/MMBooleanNode.h>
#import <GnuSpeech/MMBooleanParser.h>
#import <GnuSpeech/MMBooleanTerminal.h>
#import <GnuSpeech/MMFormulaExpression.h>
#import <GnuSpeech/MMFormulaNode.h>
#import <GnuSpeech/MMFormulaParser.h>
#import <GnuSpeech/MMFormulaTerminal.h>
#import <GnuSpeech/MMFRuleSymbols.h>

// Text Processing
#import <GnuSpeech/GSDBMPronunciationDictionary.h>
#import <GnuSpeech/GSPronunciationDictionary.h>
#import <GnuSpeech/GSSimplePronunciationDictionary.h>
#import <GnuSpeech/GSSuffix.h>
#import <GnuSpeech/TTSNumberPronunciations.h>
#import <GnuSpeech/TTSParser.h>

// Tube
#import <GnuSpeech/TRMData.h>
#import <GnuSpeech/TRMSynthesizer.h>
