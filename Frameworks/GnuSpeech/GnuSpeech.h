////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
//  
//  Contributors: Steve Nygard
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
////////////////////////////////////////////////////////////////////////////////
//
//  GnuSpeech.h
//  GnuSpeech
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.9.1
//
////////////////////////////////////////////////////////////////////////////////

// Archiving
#import <GnuSpeech/GSXMLFunctions.h>
#import <GnuSpeech/MUnarchiver.h>
#import <GnuSpeech/MXMLArrayDelegate.h>
#import <GnuSpeech/MXMLDictionaryDelegate.h>
#import <GnuSpeech/MXMLIgnoreTreeDelegate.h>
#import <GnuSpeech/MXMLParser.h>
#import <GnuSpeech/MXMLPCDataDelegate.h>
#import <GnuSpeech/MXMLReferenceArrayDelegate.h>
#import <GnuSpeech/MXMLReferenceDictionaryDelegate.h>
#import <GnuSpeech/MXMLStringArrayDelegate.h>

#ifndef GNUSTEP
// Compatibility-TypedStream
#import <GnuSpeech/FormulaExpression.h>
#import <GnuSpeech/FormulaTerminal.h>
#import <GnuSpeech/MMOldFormulaNode.h>
#import <GnuSpeech/ParameterList.h>
#import <GnuSpeech/RuleList.h>
#import <GnuSpeech/SymbolList.h>
#import <GnuSpeech/TargetList.h>
#endif

// Extensions
#import <GnuSpeech/NSArray-Extensions.h>
#import <GnuSpeech/NSCharacterSet-Extensions.h>
#import <GnuSpeech/NSFileManager-Extensions.h>
#import <GnuSpeech/NSObject-Extensions.h>
#import <GnuSpeech/NSScanner-Extensions.h>
#import <GnuSpeech/NSString-Extensions.h>

// MonetModel
#import <GnuSpeech/CategoryList.h>
#import <GnuSpeech/driftGenerator.h>
#import <GnuSpeech/Event.h>
#import <GnuSpeech/EventList.h>
#import <GnuSpeech/MDocument.h>
#import <GnuSpeech/MMCategory.h>
#import <GnuSpeech/MMEquation.h>
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
#import <GnuSpeech/MonetList.h>
#import <GnuSpeech/NamedList.h>
#import <GnuSpeech/PhoneList.h>

// Parsers
#import <GnuSpeech/GSParser.h>
#import <GnuSpeech/MMBooleanExpression.h>
#import <GnuSpeech/MMBooleanNode.h>
#import <GnuSpeech/MMBooleanParser.h>
#import <GnuSpeech/MMBooleanSymbols.h>
#import <GnuSpeech/MMBooleanTerminal.h>
#import <GnuSpeech/MMFormulaExpression.h>
#import <GnuSpeech/MMFormulaNode.h>
#import <GnuSpeech/MMFormulaParser.h>
#import <GnuSpeech/MMFormulaSymbols.h>
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
