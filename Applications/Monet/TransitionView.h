//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Cocoa/Cocoa.h>
#import <GnuSpeech/GnuSpeech.h> // For MMFRuleSymbols

@class MonetList, MModel, MMPoint, MMSlope, MMTransition;
@class TransitionView;

@protocol TransitionViewNotifications
- (void)transitionViewSelectionDidChange:(NSNotification *)aNotification;
@end

@protocol TransitionViewDelegate
- (BOOL)transitionView:(TransitionView *)aTransitionView shouldAddPoint:(MMPoint *)aPoint;
@end

extern NSString *TransitionViewSelectionDidChangeNotification;

// TODO (2004-03-22): Make this an NSControl subclass.
@interface TransitionView : NSControl <NSTextDelegate>
{
    MMFRuleSymbols _parameters;

    NSFont *timesFont;

    MMTransition *transition;

    NSMutableArray *samplePostures;
    NSMutableArray *displayPoints;
    NSMutableArray *displaySlopes;
    NSMutableArray *selectedPoints;

    NSPoint selectionPoint1;
    NSPoint selectionPoint2;

    MMSlope *editingSlope;
    NSTextFieldCell *textFieldCell;
    NSText *nonretained_fieldEditor;

    NSUInteger zeroIndex;
    NSInteger sectionAmount;

    MModel *model;

    struct {
        unsigned int shouldDrawSelection:1;
        unsigned int shouldDrawSlopes:1;
    } flags;

    id nonretained_delegate;
}

- (id)initWithFrame:(NSRect)frameRect;
- (void)dealloc;

- (NSUInteger)zeroIndex;
- (void)setZeroIndex:(NSUInteger)newZeroIndex;

- (NSInteger)sectionAmount;
- (void)setSectionAmount:(NSInteger)newSectionAmount;

- (MModel *)model;
- (void)setModel:(MModel *)newModel;

- (void)_updateFromModel;
- (void)updateTransitionType;

- (double)ruleDuration;
- (void)setRuleDuration:(double)newValue;

- (double)beatLocation;
- (void)setBeatLocation:(double)newValue;

- (double)mark1;
- (void)setMark1:(double)newValue;

- (double)mark2;
- (void)setMark2:(double)newValue;

- (double)mark3;
- (void)setMark3:(double)newValue;

- (IBAction)takeRuleDurationFrom:(id)sender;
- (IBAction)takeBeatLocationFrom:(id)sender;
- (IBAction)takeMark1From:(id)sender;
- (IBAction)takeMark2From:(id)sender;
- (IBAction)takeMark3From:(id)sender;

- (BOOL)shouldDrawSelection;
- (void)setShouldDrawSelection:(BOOL)newFlag;

- (BOOL)shouldDrawSlopes;
- (void)setShouldDrawSlopes:(BOOL)newFlag;

- (id)delegate;
- (void)setDelegate:(id)newDelegate;

// Drawing
- (void)drawRect:(NSRect)rect;

- (void)clearView;
- (void)drawGrid;
- (void)drawEquations;
- (void)drawPhones;
- (void)drawTransition;
- (void)updateDisplayPoints;
- (void)highlightSelectedPoints;

// Event handling
- (BOOL)acceptsFirstResponder;
- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent;
- (void)mouseDown:(NSEvent *)mouseEvent;
- (void)mouseDragged:(NSEvent *)mouseEvent;
- (void)mouseUp:(NSEvent *)mouseEvent;
- (void)keyDown:(NSEvent *)keyEvent;

// View geometry
- (CGFloat)sectionHeight;
- (NSPoint)graphOrigin;
- (CGFloat)timeScale;
- (NSRect)rectFormedByPoint:(NSPoint)point1 andPoint:(NSPoint)point2;
- (CGFloat)slopeMarkerYPosition;
- (NSRect)slopeMarkerRect;

// Slopes
- (void)drawSlopes;
- (void)_setEditingSlope:(MMSlope *)newSlope;
- (void)editSlope:(MMSlope *)aSlope startTime:(CGFloat)startTime endTime:(CGFloat)endTime;
- (MMSlope *)getSlopeMarkerAtPoint:(NSPoint)aPoint startTime:(CGFloat *)startTime endTime:(CGFloat *)endTime;

// NSTextView delegate method, used for editing slopes
- (void)textDidEndEditing:(NSNotification *)notification;

// Selection
- (MMPoint *)selectedPoint;
- (void)selectGraphPointsBetweenPoint:(NSPoint)point1 andPoint:(NSPoint)point2;
- (void)_selectionDidChange;

// Actions
- (IBAction)deleteBackward:(id)sender;
- (IBAction)groupInSlopeRatio:(id)sender;

// Publicly used API
- (MMTransition *)transition;
- (void)setTransition:(MMTransition *)newTransition;

@end
