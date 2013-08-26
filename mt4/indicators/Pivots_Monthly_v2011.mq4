//+------------------------------------------------------------------+
//|                                                  WeeklyPivot.mq4 |
//|  I found the original indicator in TSD forum posted by heliyaun. |
//|                                       I don´t know how wrote it. |
//| I like it because have mondays fixed for broker with GMT outside |
//| london time.                                                     |
//| So, I added some stuff, labels, fix, etc. and them, I wrote the|
//|             Medians SR, and then, I wrote the same for Monthlies |
//|                                                                  |
//|                                                           Enjoy. |
//|                                                                  |
//|                                           Linuxser, January 2007 |
//|                                                                  |
//+------------------------------------------------------------------+

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 DimGray
#property indicator_color2 Salmon
#property indicator_color3 Purple
#property indicator_color4 Salmon
#property indicator_color5 Purple
#property indicator_color6 Salmon
#property indicator_color7 Purple

//---- input parameters

extern color     SupportLabelColor=Salmon;
extern color     ResistanceLabelColor=Purple;
extern color     PivotLabelColor=DimGray;
extern int       fontsize=10;
extern int       LabelShift = 0;

//---- buffers
double MPBuffer[];
double MS1Buffer[];
double MR1Buffer[];
double MS2Buffer[];
double MR2Buffer[];
double MS3Buffer[];
double MR3Buffer[];
string Pivot="MonthlyPivotPoint",Sup1="M_S 1", Res1="M_R 1";
string Sup2="M_S 2", Res2="M_R 2", Sup3="M_S 3", Res3="M_R 3";
double MP,MS1,MR1,MS2,MR2,MS3,MR3;
double last_month_high, last_month_low, this_month_open, last_month_close;
datetime LabelShiftTime;
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here

   ObjectDelete("monthlyPivot");
   ObjectDelete("MSup1");
   ObjectDelete("MRes1");
   ObjectDelete("MSup2");
   ObjectDelete("MRes2");
   ObjectDelete("MSup3");
   ObjectDelete("MRes3");   

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;


//---- indicator line
   SetIndexStyle(0,DRAW_LINE,EMPTY);
   SetIndexStyle(1,DRAW_LINE,EMPTY);
   SetIndexStyle(2,DRAW_LINE,EMPTY);
   SetIndexStyle(3,DRAW_LINE,EMPTY);
   SetIndexStyle(4,DRAW_LINE,EMPTY);
   SetIndexStyle(5,DRAW_LINE,EMPTY);
   SetIndexStyle(6,DRAW_LINE,EMPTY);
   SetIndexBuffer(0,MPBuffer);
   SetIndexBuffer(1,MS1Buffer);
   SetIndexBuffer(2,MR1Buffer);
   SetIndexBuffer(3,MS2Buffer);
   SetIndexBuffer(4,MR2Buffer);
   SetIndexBuffer(5,MS3Buffer);
   SetIndexBuffer(6,MR3Buffer);


//---- name for DataWindow and indicator subwindow label
   short_name="Pivot Point Monthly";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);

//----
   SetIndexDrawBegin(0,1);
//----
 

//----
   return(0);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()

  {
   int counted_bars=IndicatorCounted();

   int limit, i;
//---- indicator calculation
if (counted_bars==0)
{
   if(Period() > 1440)
   {
   Print("Error - Chart period is greater than 1 day.");
   return(-1); // then exit
   }
   
}
   if(counted_bars<0) return(-1);

   limit=(Bars-counted_bars)-1;


for (i=limit; i>=0;i--)
{ 


   // Monday	
	if(TimeDay(Time[i])<=3 && TimeDay(Time[i+1])>=26)
	{
		last_month_close = Close[i+1];
		this_month_open = Open[i];

		// monthlyPivot
	MP = (last_month_high + last_month_low + last_month_close) / 3;

   MR1 = (2*MP)-last_month_low;
   MS1 = (2*MP)-last_month_high;
   MR2 = MP+(last_month_high - last_month_low);
   MS2 = MP-(last_month_high - last_month_low);
   MR3 = last_month_high+(2*(MP-last_month_low));
   MS3 = last_month_low-(2*(last_month_high-MP)); 
  
   last_month_low=Low[i]; last_month_high=High[i];

   LabelShiftTime = Time[LabelShift];

	ObjectCreate("MonthlyPivot", OBJ_TEXT, 0,LabelShiftTime,0);
   ObjectSetText("MonthlyPivot", "                            Monthly Pivot Point  "+DoubleToStr(MP,4),fontsize,"Arial",PivotLabelColor);
   SetIndexLabel(0, "Monthly Pivot Point");   
   ObjectCreate("MSup1", OBJ_TEXT, 0, LabelShiftTime, 0);   
   ObjectSetText("MSup1", "                   Mo S1 "+DoubleToStr(MS1,4),fontsize,"Arial",SupportLabelColor);
   SetIndexLabel(1, "MSup1");   
   ObjectCreate("MRes1", OBJ_TEXT, 0, LabelShiftTime, 0);   
   ObjectSetText("MRes1", "                   Mo R1  "+DoubleToStr(MR1,4),fontsize,"Arial",ResistanceLabelColor);
   SetIndexLabel(2, "MRes1");   
   ObjectCreate("MSup2", OBJ_TEXT, 0, LabelShiftTime, 0);   
   ObjectSetText("MSup2", "                   Mo S2  "+DoubleToStr(MS2,4),fontsize,"Arial",SupportLabelColor);
   SetIndexLabel(3, "MSup2");   
   ObjectCreate("MRes2", OBJ_TEXT, 0, LabelShiftTime, 0);
   ObjectSetText("MRes2", "                   Mo R2  "+DoubleToStr(MR2,4),fontsize,"Arial",ResistanceLabelColor);
   SetIndexLabel(4, "MRes2");   
   ObjectCreate("MSup3", OBJ_TEXT, 0, LabelShiftTime, 0);   
   ObjectSetText("MSup3", "                   Mo S3  "+DoubleToStr(MS3,4),fontsize,"Arial",SupportLabelColor);
   SetIndexLabel(5, "MSup3");   
   ObjectCreate("MRes3", OBJ_TEXT, 0, LabelShiftTime, 0);   
   ObjectSetText("MRes3", "                   Mo R3  "+DoubleToStr(MR3,4),fontsize,"Arial",ResistanceLabelColor);
	SetIndexLabel(6, "MRes3");
	
	ObjectMove("MonthlyPivot", 0, LabelShiftTime,MP);
   ObjectMove("MSup1", 0, LabelShiftTime,MS1);
   ObjectMove("MRes1", 0, LabelShiftTime,MR1);
   ObjectMove("MSup2", 0, LabelShiftTime,MS2);
   ObjectMove("MRes2", 0, LabelShiftTime,MR2);
   ObjectMove("MSup3", 0, LabelShiftTime,MS3);
   ObjectMove("MRes3", 0, LabelShiftTime,MR3);

}   
    
    last_month_high = MathMax(last_month_high, High[i]);
 	 last_month_low = MathMin(last_month_low, Low[i]);   
    MPBuffer[i]=MP;
    MS1Buffer[i]=MS1;
    MR1Buffer[i]=MR1;
    MS2Buffer[i]=MS2;
    MR2Buffer[i]=MR2;
    MS3Buffer[i]=MS3;
    MR3Buffer[i]=MR3;

}

//----
   return(0);
  }
//+------------------------------------------------------------------+