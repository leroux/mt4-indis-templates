//+------------------------------------------------------------------+
//|                                                     Yearly Pivot |
//|                                    Copyright © 2006, Profitrader |
//|                                    Coded/Verified by Profitrader |
//| minor fixes 2010/11/25 myke@omgcats.com                          |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Profitrader."
#property link      "profitrader@inbox.ru"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 DimGray
#property indicator_color2 Lime
#property indicator_color3 Red
#property indicator_color4 Lime
#property indicator_color5 Red
#property indicator_color6 Lime
#property indicator_color7 Red

extern int LabelShift = 0;

//---- buffers
double PBuffer[];
double S1Buffer[];
double R1Buffer[];
double S2Buffer[];
double R2Buffer[];
double S3Buffer[];
double R3Buffer[];

double P,S1,R1,S2,R2,S3,R3,last_year_high,last_year_low,last_year_close,this_year_open;
datetime LabelShiftTime;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexBuffer(0,PBuffer);
   SetIndexBuffer(1,S1Buffer);
   SetIndexBuffer(2,R1Buffer);
   SetIndexBuffer(3,S2Buffer);
   SetIndexBuffer(4,R2Buffer);
   SetIndexBuffer(5,S3Buffer);
   SetIndexBuffer(6,R3Buffer);
   SetIndexStyle(0,DRAW_LINE,0,2);
   SetIndexStyle(1,DRAW_LINE,0,2);
   SetIndexStyle(2,DRAW_LINE,0,2);
   SetIndexStyle(3,DRAW_LINE,0,2);
   SetIndexStyle(4,DRAW_LINE,0,2);
   SetIndexStyle(5,DRAW_LINE,0,2);
   SetIndexStyle(6,DRAW_LINE,0,2);
   SetIndexLabel(0,"Yearly Pivot Point");
   SetIndexLabel(1,"Yearly Support 1");
   SetIndexLabel(2,"Yearly Resistant 1");
   SetIndexLabel(3,"Yearly Support 2");
   SetIndexLabel(4,"Yearly Resistant 2");
   SetIndexLabel(5,"Yearly Support 3");
   SetIndexLabel(6,"Yearly Resistant 3");
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectDelete("Yearly Pivot");
   ObjectDelete("Yearly Sup1");
   ObjectDelete("Yearly Res1");
   ObjectDelete("Yearly Sup2");
   ObjectDelete("Yearly Res2");
   ObjectDelete("Yearly Sup3");
   ObjectDelete("Yearly Res3");   
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int i,counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;  
   int limit=Bars-counted_bars;
   
   if(Period()>PERIOD_W1) return(-1);

   for(i=limit-1; i>=0; i--)
      {
       // 1sts Days of Year
	    if(TimeDayOfYear(Time[i])<=10 && TimeDayOfYear(Time[i+1])>=355)
	      {
		    last_year_close=Close[i+1];
		    this_year_open=Open[i];		
		    P=(last_year_high+last_year_low+last_year_close)/3;
          R1=(2*P)-last_year_low;
          S1=(2*P)-last_year_high;
          R2=P+(last_year_high-last_year_low);
          S2=P-(last_year_high-last_year_low);
          R3=last_year_high+(2*(P-last_year_low));
          S3=last_year_low-(2*(last_year_high-P)); 

	  LabelShiftTime = Time[LabelShift];

	  ObjectCreate("Yearly Pivot",OBJ_TEXT,0,LabelShiftTime,0);
	  ObjectSetText("Yearly Pivot","YPP "+DoubleToStr(P,4),10,"Arial",DimGray);
	  ObjectCreate("Yearly Sup1",OBJ_TEXT,0,LabelShiftTime,0);
	  ObjectSetText("Yearly Sup1","YS1 "+DoubleToStr(S1,4),10,"Arial",Lime);
	  ObjectCreate("Yearly Res1",OBJ_TEXT,0,LabelShiftTime,0);
	  ObjectSetText("Yearly Res1","YR1 "+DoubleToStr(R1,4),10,"Arial",Red);
	  ObjectCreate("Yearly Sup2",OBJ_TEXT,0,LabelShiftTime,0);
	  ObjectSetText("Yearly Sup2","YS2 "+DoubleToStr(S2,4),10,"Arial",Lime);
	  ObjectCreate("Yearly Res2",OBJ_TEXT,0,LabelShiftTime,0);
	  ObjectSetText("Yearly Res2","YR2 "+DoubleToStr(R2,4),10,"Arial",Red);
	  ObjectCreate("Yearly Sup3",OBJ_TEXT,0,LabelShiftTime,0);
	  ObjectSetText("Yearly Sup3","YS3 "+DoubleToStr(S3,4),10,"Arial",Lime);
	  ObjectCreate("Yearly Res3",OBJ_TEXT,0,LabelShiftTime,0);
	  ObjectSetText("Yearly Res3","YR3 "+DoubleToStr(R3,4),10,"Arial",Red);
	  ObjectMove("Yearly Pivot",0,LabelShiftTime,P);
          ObjectMove("Yearly Sup1",0,LabelShiftTime,S1);
          ObjectMove("Yearly Res1",0,LabelShiftTime,R1);
          ObjectMove("Yearly Sup2",0,LabelShiftTime,S2);
          ObjectMove("Yearly Res2",0,LabelShiftTime,R2);
          ObjectMove("Yearly Sup3",0,LabelShiftTime,S3);
          ObjectMove("Yearly Res3",0,LabelShiftTime,R3);
          last_year_low=Low[i];
          last_year_high=High[i];
         }       
       last_year_low=MathMin(last_year_low,Low[i]);   
       last_year_high=MathMax(last_year_high,High[i]);
       PBuffer[i]=P;
       S1Buffer[i]=S1;
       R1Buffer[i]=R1;
       S2Buffer[i]=S2;
       R2Buffer[i]=R2;
       S3Buffer[i]=S3;
       R3Buffer[i]=R3;
      }
//----
   return(0);
  }
//+------------------------------------------------------------------+


