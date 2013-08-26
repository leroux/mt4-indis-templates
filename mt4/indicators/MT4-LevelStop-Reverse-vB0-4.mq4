//+------------------------------------------------------------------+
//|                                            MT4-LevelStop-Reverse |
//|                                                 Version Beta 0.4 |
//|                     Copyright © 2007, Bruce Hellstrom (brucehvn) |
//|                                              bhweb@speakeasy.net |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+

/////////////////////////////////////////////////////////////////////
// Version 0.4 Beta
//
// This is a port of the VTTrader VT-LevelStop-Reverse trading system.
// This is ported as an MT4 indicator only and perhaps can be evolved
// into an EA later.
//
// This is a beta version
//
/////////////////////////////////////////////////////////////////////

/*

This is a combination of two VT Trader trading systems.  The first is the default
VT-LevelStop-Reverse and the second is one that was modified to allow customizing
the ATR settings for calculating the stop line.  I've tried to combine these 2
versions into a single MT4 indicator.

The default VT version allows you to use two modes, optimized, and manual.
Optimized mode calculates the stop line by using a 14 period EMA smoothed
ATR(14) multiplied by a fixed multiplier of 2.824. In manual mode, you set a
fixed number of pips you want the stop line to be drawn. In my MT4 version,
there are two modes:

1. ATR mode (customizable ATR period, multiplier, and smoothing)
2. Fixed stop mode (customizable fixed stop)

The input parameters are as follows:

* UseATRMode -     This calculates the stop line based on ATR using customizable period, multiplier and smoothing.
* NonATRStopPips - If "UseATRMode" is false, then this value is the number of fixed pips to place the stop line.
* ATRPeriod -      If "UseATRMode" is true, then this sets the ATR period.
* ATRMultiplier -  If "UseATRMode" is true, then the ATR value will be multiplied by this value when calculating the stop line.
* ATRSmoothing -   If "UseATRMode" is true, then this will smooth the selected ATR with an EMA of this smoothing period.
* UpArrowColor -   The color the Up arrows will display in.
* DnArrowColor -   The color the Down arrows will display in.
* ArrowDistance -  This can adjust the distance away from the stop line that the arrows appear. By default, the arrows appear directly above or below the stop line. A positive number here will move the arrows further away from the price.  A negative number will move it closer to the price.

For the default VT-LevelStop-Reverse behavior, set the following:
UseATRMode = true
ATRPeriod = 14
ATRMultiplier = 2.824
ATRSmoothing = 14

To use this indicator, copy it to your <MetaTrader Folder>\experts\indicators folder. Then restart MT4. It will appear in the custom indicators list.

This is version Beta 0.4.  As I get feedback, I will release newer versions as needed.

Revision History

Version Beta 0.2
* Minor bug fixes.
* Remove extra "UseVTDefault" option.
* Add smoothing option for compatibility with default VT version.

Version Beta 0.3
* Delete objects at startup.
* Use a more unique object name prefix.
* Change ATRBuffer and SmoothBuffer to be non-indicator buffers.
* No need for UpSignal and DnSignal to be buffers.
* Change arrows to display at the stop line.
* Fix bug on current bar drawing that would cause multiple arrows to appear.

Version Beta 0.4
* Fix bug in non-indicator buffers that was causing erroneous data in the ATR buffer and smoothing buffer.

*/


#property copyright "Copyright © 2007, Bruce Hellstrom (brucehvn)"
#property link      "http: //www.metaquotes.net/"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow
#property indicator_style1 STYLE_SOLID

#define INDICATOR_VERSION ""
#define VTS_OBJECT_PREFIX "vtsbh2483-"
#define MAX_OBJECT_NUM 32768


//---- input parameters

extern bool UseATRMode = true;
extern int NonATRStopPips = 100;
extern int ATRPeriod = 10;
extern double ATRMultiplier = 3.0;
extern int ATRSmoothing = 0;
extern color UpArrowColor = Lime;
extern color DnArrowColor = Red;
extern int ArrowDistance = 0;

//---- buffers
double TrStopLevel[];

//---- variables
double ATRBuffer[];
double SmoothBuffer[];
string ShortName;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {

    int DrawBegin = 0;
    if ( UseATRMode ) {
        DrawBegin = ATRPeriod;
    }
    
    IndicatorBuffers( 1 );
    SetIndexStyle( 0, DRAW_LINE, STYLE_SOLID, 1 );
    SetIndexBuffer( 0, TrStopLevel );
    SetIndexDrawBegin( 0, DrawBegin );
    
    ShortName = "Minibahn Mafia System (http://minibahn.blogspot.com) " + INDICATOR_VERSION + "(";
    
    if ( UseATRMode ) {
        ShortName = StringConcatenate( ShortName, "ATRMode ", ATRPeriod, ", ",
                                       ATRMultiplier, ", ", ATRSmoothing, " )" );
    }
    else {
        ShortName = StringConcatenate( ShortName, "Manual Mode Stop = ", NonATRStopPips, " )" );
    }
    
    IndicatorShortName( ShortName );
    SetIndexLabel( 0, ShortName );
    
    Print( ShortName );
    Print( "Copyright (c) 2007 - Bruce Hellstrom, bhweb@speakeasy.net" );
    
    MathSrand( TimeLocal() );
    
    // Cleanup any leftover objects from previous runs
    DeleteAllArrowObjects();
    
    return( 0 );
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                         |
//+------------------------------------------------------------------+
int deinit() {
    DeleteAllArrowObjects();
    return( 0 );
}

//+------------------------------------------------------------------+
//| Function run on every tick                                       |
//+------------------------------------------------------------------+
int start() {
    Comment( ShortName );
    
    int ictr;
    int counted_bars = IndicatorCounted();
    
    // Check for errors
    if ( counted_bars < 0 ) {
        return( -1 );
    }

    // Last bar will be recounted
    if ( counted_bars > 0 ) {
        counted_bars--;
    }
    
    int limit = Bars - counted_bars;
    ictr = limit - 1;
    
    if ( UseATRMode && Bars < ATRPeriod ) {
        return( 0 );
    }
    
    // Make sure buffers are sized correctly
    int buff_size = ArraySize( TrStopLevel );
    if ( ArraySize( ATRBuffer ) != buff_size ) {
        ArraySetAsSeries( ATRBuffer, false );
        ArrayResize( ATRBuffer, buff_size );
        ArraySetAsSeries( ATRBuffer, true );

        ArraySetAsSeries( SmoothBuffer, false );
        ArrayResize( SmoothBuffer, buff_size );
        ArraySetAsSeries( SmoothBuffer, true );
    }
    
    int xctr;
    
    if ( UseATRMode ) {
        // First calculate the ATR
        for ( xctr = 0; xctr < limit; xctr++ ) {
            ATRBuffer[xctr] = iATR( NULL, 0, ATRPeriod, xctr );
        }
            
        // Smooth the ATR if necessary
        if ( ATRSmoothing > 0 ) {
            for ( xctr = 0; xctr < limit; xctr++ ) {
                SmoothBuffer[xctr] = Wilders( ATRBuffer, ATRSmoothing, xctr );
            }
        }
    }
    
    
    for ( xctr = ictr; xctr >= 0; xctr-- ) {
         // Calculate the stop amount
        double DeltaStop = NonATRStopPips * Point;
        
        // Calculate our stop value based on ATR if required
        if ( UseATRMode ) {
            if ( ATRSmoothing > 0 ) {
                DeltaStop = NormalizeDouble( SmoothBuffer[xctr] * ATRMultiplier, 4 );
            }
            else {
                DeltaStop = NormalizeDouble( ATRBuffer[xctr] * ATRMultiplier, 4 );
            }
        }
        
        // Figure out where the current bar's stop level should be
        double NewStopLevel;
        double PrevStop = TrStopLevel[xctr + 1];
        
        if ( Close[xctr] == PrevStop ) {
            NewStopLevel = PrevStop;
        }
        else {
            if ( Close[xctr + 1] <= PrevStop && Close[xctr] < PrevStop ) {
                NewStopLevel = MathMin( PrevStop, ( Close[xctr] + DeltaStop ) );
            }
            else {
                if ( Close[xctr + 1] >= PrevStop && Close[xctr] > PrevStop ) {
                    NewStopLevel = MathMax( PrevStop, ( Close[xctr] - DeltaStop ) );
                }
                else {
                    if ( Close[xctr] > PrevStop ) {
                        NewStopLevel = Close[xctr] - DeltaStop;
                    }
                    else {
                        NewStopLevel = Close[xctr] + DeltaStop;
                    }
                }
            }
        }
        
        TrStopLevel[xctr] = NewStopLevel;
        
        // Can't do the arrows until the bar closes
        if ( xctr > 0 ) {
            // Figure out the up/down arrows
            bool Up = false;
            bool Dn = false;
        
            if ( Close[xctr] > TrStopLevel[xctr] && Close[xctr + 1] <= TrStopLevel[xctr + 1] ) {
                Up = true;
                double UpSignal = TrStopLevel[xctr] - ( ArrowDistance * Point );
                string ObjName = GetNextObjectName();
                ObjectCreate( ObjName, OBJ_ARROW, 0, Time[xctr], UpSignal );
                ObjectSet( ObjName, OBJPROP_COLOR, UpArrowColor );
                ObjectSet( ObjName, OBJPROP_ARROWCODE, 233 );
            }
            
            if ( Close[xctr] < TrStopLevel[xctr] && Close[xctr + 1] >= TrStopLevel[xctr + 1] ) {
                Dn = true;
                double DnSignal = TrStopLevel[xctr] + ( 2 * Point ) + ( ArrowDistance * Point );
                ObjName = GetNextObjectName();
                ObjectCreate( ObjName, OBJ_ARROW, 0, Time[xctr], DnSignal );
                ObjectSet( ObjName, OBJPROP_COLOR, DnArrowColor );
                ObjectSet( ObjName, OBJPROP_ARROWCODE, 234 );
            }
        
            // Reverse TrStopLevel According to Up and Down Signals
            if ( Up ) {
                TrStopLevel[xctr] = Close[xctr] - DeltaStop;
            }
            else {
                if ( Dn ) {
                    TrStopLevel[xctr] = Close[xctr] + DeltaStop;
                }
            }
        }
    }
        
    return( 0 );
}


//+------------------------------------------------------------------+
//| Gets the next object index so they can be deleted later          |
//+------------------------------------------------------------------+
string GetNextObjectName() {
    int rand_val = MathRand() + 1;
    string retval = VTS_OBJECT_PREFIX + rand_val;
    return( retval );
}
        

//+------------------------------------------------------------------+
//| Wilders Calculation                                              |
//+------------------------------------------------------------------+
double Wilders( double& indBuffer[], int Periods, int shift ) {
    double retval = 0.0;
    retval = iMAOnArray( indBuffer, 0, ( Periods * 2 ) - 1, 0, MODE_EMA, shift );
    return( retval );
}
    
//+------------------------------------------------------------------+
//| Delete all the arrow objects                                     |
//+------------------------------------------------------------------+
void DeleteAllArrowObjects() {
    for ( int ictr = 0; ictr < MAX_OBJECT_NUM; ictr++ ) {
        string ObjName = VTS_OBJECT_PREFIX + ( ictr + 1 );
        ObjectDelete( ObjName );
    }
    return;
}
    

//+------------------------------------------------------------------+