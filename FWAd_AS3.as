/***
FWAd_AS3 版本:v1.0
*/

package{
	import flash.display.*;
	import flash.events.*;
	import flash.system.*;
	import flash.utils.*;
	import flash.text.*;
	import flash.net.*;
	import flash.ui.*;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	
	public class FWAd_AS3 extends Sprite{
		public static const ifLoadFrameworkErrorCanPlayGame:Boolean=true;//执行代码写在 checkLoadGameCompleteAndTryStart 里
		public static const loadFrameworkTimeoutTime:int=8;//加载 Framework 判定超时秒数
		public static const loadFrameworkTimes:int=2;//如果加载 Framework 失败，尝试重新加载的次数
		
		public static const ifAdFailCanPlayGame:Boolean=true;//如果广告加载失败, 是否可以玩游戏. 建议性的标记, 执行代码写在 Framework 里
		public static const ifAddCallBackErrorCanPlayGame:Boolean=false;//如果没加 always 或是其它原因引起的向容器注册函数失败, 是否可以玩游戏. 建议性的标记, 执行代码写在 Framework 里
		public var _FWAd:Object;
		
		public static const frameworDomain:String="flashcfg.youyouwin.com";
		public static const frameworkSWFPath:String="http://"+frameworDomain+"/Framework2.swf";
		
		public static var id:String;
		public static var AD_TYPE_LOADING:String="loading";//缓冲广告
		public static var AD_TYPE_CONTAINER:String="container";//容器广告
		public static var adType:String=AD_TYPE_LOADING;
		
		public static var frameworkLoader:Loader;//加载 framework 用
		
		public static var lc:LocalConnection;
		public static var lc_connName:String;
		public static var lc_sendName:String;
		
		public static var xx:int;
		public static var yy:int;
		public static var wid:int;
		public static var hei:int;
		
		public static var loadGameCompleted:Boolean;//标记游戏是否加载完毕
		public static var loadFrameworkSuccess:Boolean;//标记 framework 是否加载完毕
		public static var loadFrameworkFailed:Boolean;//标记 framework 是否加载失败
		public static var restLoadFrameworkTimes:int;
		public static var frameworkInitFinished:Boolean;//标记 framework 是否初始化完毕
		public static var canNotShowAd:Boolean;//标记是否不能显示广告
		
		//
		//public var bg:Sprite;
		//public var loading_txt:TextField;
		public var loadingBar:Sprite;
		public var loadingBar_bar:Sprite;
		
		public static var onClickStartBtn:Function;
		
		public static var _root:*;
		
		public static function showAd(_adValues:Object = null):void
		{
			var adValues:Object={
				x:xx,//广告位置x
				y:yy,//广告位置y
				wid:wid,//广告宽度
				hei:hei,//广告高度
				id:id,//广告id
				adType:AD_TYPE_CONTAINER//广告类型是容器广告
			}

			for(var valueName:String in _adValues){
				adValues[valueName]=_adValues[valueName];
			}

			var container:Sprite=adValues.container||_root;
			if(container){
				container.addChild(new FWAd_AS3(adValues));
			}else{
				trace("未指定容器,请改成例如: FWAd_AS3.showAd({container:root}");
			}

		}
		
		public function FWAd_AS3(adValues:Object){
			xx=adValues.x;
			yy=adValues.y;
			wid=adValues.wid;
			hei=adValues.hei;
			id=adValues.id;
			adType=adValues.adType;
			if(adValues.onClickCloseBtn){
				onClickStartBtn=adValues.onClickCloseBtn;
			}else{
				onClickStartBtn=adValues.onClickStartBtn;
			}

			_FWAd=FWAd_AS3;
			
			this.addEventListener(Event.ADDED_TO_STAGE,added);
		}
		
		private function added(event:Event):void {
			
			
			this.removeEventListener(Event.ADDED_TO_STAGE,added);
			this.addEventListener(Event.REMOVED_FROM_STAGE,removed);
			
			//设置权限
			Security.allowDomain(frameworDomain);
			Security.allowInsecureDomain(frameworDomain);

			//屏蔽右键菜单
			try{
				fscommand("showMenu","false");
			}catch(e:Error){
			}
			
			_root=stage.getChildAt(0);
			_root.contextMenu=new ContextMenu();
			_root.contextMenu.hideBuiltInItems();
			
			//禁止使用快捷键(例如 ctrl+enter 跳过广告)
			try{
				fscommand("trapallkeys","true");
			}catch(e:Error){
			}
			
			/*
			bg=new Sprite();
			this.addChild(bg);
			var g:Graphics=bg.graphics;
			g.clear();
			g.beginFill(0x000000);
			g.drawRect(0,0,wid+xx*2,hei+yy*2);
			g.endFill();
			*/
			
			
			loadGameCompleted=_root.loaderInfo.bytesLoaded==_root.loaderInfo.bytesTotal;
			trace("FWAd_AS3 loadGameCompleted="+loadGameCompleted);
			
			if(frameworkLoader){
				frameworkInitFinished=true;
				checkLoadGameCompleteAndTryStart();
				if(frameworkInitFinished){
					lc.client=this;
					lc.send(lc_sendName,"that2this","reset");//通知 framework 重新开始显示广告
				}
			}else{
				//第一次加载
				frameworkLoader=new Loader();
				frameworkLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadFrameworkComplete);
				frameworkLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,loadFrameworkError);
				
				restLoadFrameworkTimes=loadFrameworkTimes;
				loadFramework();
			}
			
			this.addChild(frameworkLoader);
			
			//loading_txt=new TextField();
			//var txt_sp:Sprite=new Sprite();
			//this.addChild(txt_sp);
			//txt_sp.filters=[new DropShadowFilter(0,0,0x000000,1,2,2,4)];
			//txt_sp.addChild(loading_txt);
			//loading_txt.autoSize=TextFieldAutoSize.LEFT;
			//loading_txt.textColor=0xffffff;//<span style="font-size:16px">无标题文档</span>
			//loading_txt.text="";
			//loading_txt.x=wid-90+xx;
			//loading_txt.y=hei-20+yy;//右下角对齐
			//var style:StyleSheet=new StyleSheet();
			//style.parseCSS(".size14{font-size: 14px}");
			//loading_txt.styleSheet=style;
			
			//
			var loadingBar_hei:Number=8;
			var loadingBar_x:Number=10;
			var loadingBar_wid:Number=wid-2*loadingBar_x;
			loadingBar=new Sprite();
			loadingBar.x=loadingBar_x;
			loadingBar.y=hei-loadingBar_hei-6;
			this.addChild(loadingBar);
			
			var loadingBar_bottom:Sprite=new Sprite();
			loadingBar.addChild(loadingBar_bottom);
			loadingBar_bar=new Sprite();
			loadingBar.addChild(loadingBar_bar);
			var loadingBar_line:Sprite=new Sprite();
			loadingBar.addChild(loadingBar_line);
			
			var g:Graphics=loadingBar_bottom.graphics;
			g.clear();
			g.beginFill(0x333333);
			g.drawRect(0,0,loadingBar_wid,loadingBar_hei);
			g.endFill();
			
			g=loadingBar_bar.graphics;
			g.clear();
			g.beginGradientFill("linear",[0xffffff,0xff9966],[1,1],[63,255],new Matrix(0.006,0,0,1,0,0));
			loadingBar_bar.rotation=90;
			g.drawRect(0,-loadingBar_wid,loadingBar_hei,loadingBar_wid);
			g.endFill();
			
			g=loadingBar_line.graphics;
			g.clear();
			g.lineStyle(1,0x666666);
			g.drawRect(0,0,loadingBar_wid,loadingBar_hei);
			g.endFill();
			
			loadingBar_bar.width=1;
			loadingBar_bar.scaleX=1;
			
			switch(adType){
				case AD_TYPE_LOADING:
				break;
				default:
					loadingBar.visible=false;
				break;
			}
			//
			
			if(loadGameCompleted){
				loadingBar.visible=false;
			}else{
				_root.loaderInfo.addEventListener(ProgressEvent.PROGRESS,loadGameProgress);
				_root.loaderInfo.addEventListener(Event.COMPLETE,loadGameComplete);
			}
		}
		
		private function removed(event:Event):void{
			this.removeEventListener(Event.REMOVED_FROM_STAGE,removed);
			_root.loaderInfo.removeEventListener(ProgressEvent.PROGRESS,loadGameProgress);
			_root.loaderInfo.removeEventListener(Event.COMPLETE,loadGameComplete);
			
			onClickStartBtn=null;
			//loading_txt=null;
			
			if(frameworkInitFinished){
				lc.send(lc_sendName,"that2this","removed");//通知 framework 被从显示列表中移除
				lc.client=new Object();
			}
		}
		private var timeoutId:int=-1;
		private function loadFramework():void{
			frameworkLoader.load(new URLRequest(frameworkSWFPath));
			clearTimeout(timeoutId);
			timeoutId=setTimeout(loadFrameworkTimeout,loadFrameworkTimeoutTime*1000);
		}
		private function lc_onStatus(event:StatusEvent):void{
			switch(event.level){
				case "error":
					trace("lc onStatus 出错 event="+event);
				break;
			}
		}
		
		//private var sendLoadGameProgressDelayTime:int;
		private function loadGameProgress(event:ProgressEvent):void{
			switch(adType){
				case AD_TYPE_LOADING:
					var percent:Number=event.bytesLoaded/event.bytesTotal;
					//loading_txt.htmlText='<span class="size14">loading '+int(percent*100)+'%</span>';
					loadingBar_bar.scaleX=1;
					loadingBar_bar.scaleY=percent;
				break;
				default:
					//loading_txt.text="";
					_root.loaderInfo.removeEventListener(ProgressEvent.PROGRESS,loadGameProgress);
				break;
			}
		}
		private function loadGameComplete(event:Event):void {
			
			trace("Load Complete");
			
			loadGameCompleted=true;//如果游戏加载完毕比加载framework快,则要把此参数传给 framework
			loadingBar.visible=false;
			checkLoadGameCompleteAndTryStart();
			if(frameworkInitFinished){
				lc.send(lc_sendName,"that2this","loadGameCompleted");//通知 framework 游戏加载完毕
			}
		}
		
		private function loadFrameworkComplete(event:Event):void{
			//trace("加载 framework 完毕");
			this.addEventListener(Event.ENTER_FRAME,checkFrameworkFirstInit);
		}
		private function checkFrameworkFirstInit(event:Event){
			try{
				var movie:AVM1Movie=frameworkLoader.content as AVM1Movie;
			}catch(e:Error){
				return;
			}
			var ran:int=Math.round(movie.getBounds(movie).x/10);//为避免误差从十位开始取
			if(ran<-1000){
				this.removeEventListener(Event.ENTER_FRAME,checkFrameworkFirstInit);
				
				lc_connName="_FWAd"+ran;
				lc_sendName="_Framework"+ran;
				lc=new LocalConnection();
				lc.allowDomain("*");
				lc.addEventListener(StatusEvent.STATUS,lc_onStatus);
				lc.connect(lc_connName);
				lc.client=this;
				
				loadFrameworkSuccess=true;
				clearTimeout(timeoutId);
				checkLoadGameCompleteAndTryStart();
				//等待 framework initFinished
			}
		}
		private function loadFrameworkTimeout():void{
			trace("loadFrameworkTimeout");
			loadFrameworkError(null);
		}
		private function loadFrameworkError(event:IOErrorEvent):void{
			trace("剩余尝试加载次数:"+restLoadFrameworkTimes);
			clearTimeout(timeoutId);
			if(--restLoadFrameworkTimes<0){
				loadFrameworkFailed=true;
				checkLoadGameCompleteAndTryStart();
			}else{
				try{
					frameworkLoader.close();
				}catch(e:Error){}
				loadFramework();
			}
		}
		
		public function that2this(...args):void{
			switch(args[0]){
				case "initFinished":
					frameworkInitFinished=true;
					lc.send(lc_sendName,"that2this","confirmInitFinished",getFWAdValuesByNameArr(args.slice(1)));
				break;
				case "AsmMachine.run()":
					try{
						var result:*=Runner.runStr16(this,args[2]);
						lc.send(lc_sendName,"that2this","AsmMachine.run()",args[1],"success",result);
					}catch(e:Error){
						lc.send(lc_sendName,"that2this","AsmMachine.run()",args[1],"error",e.toString());
					}
				break;
				case "clickStartBtn":
					clickStartBtn();
				break;
				case "canNotShowAd":
				case "noId":
					canNotShowAd=true;
					checkLoadGameCompleteAndTryStart();
				break;
			}
		}
		private function getFWAdValuesByNameArr(nameArr:Array):Object{
			var obj:Object=new Object();
			for each(var name:String in nameArr){
				obj[name]=FWAd_AS3[name];
			}
			return obj;
		}
		
		private function checkLoadGameCompleteAndTryStart():void{
			//trace("loadGameCompleted="+loadGameCompleted);
			if(loadGameCompleted){
				if(loadFrameworkFailed){
					trace("加载 framework 失败")
					if(
				   		ifLoadFrameworkErrorCanPlayGame//允许在加载广告失败后玩游戏
				   		||
				  		checkIsOurDomain()
					 ){
						trace("自动跳到游戏");
						clickStartBtn();
					}else{//不允许在加载广告失败后玩游戏
						trace("不自动跳到游戏");
					}
				}else if(canNotShowAd){
					if(checkIsOurDomain()){
						clickStartBtn();
					}
				}
			}
		}
		private function checkIsOurDomain():Boolean{
			 if(_root.loaderInfo){
				 var url:String=_root.loaderInfo.url.toLowerCase();
				 return url.indexOf(".youyouwin.com/")>0
						||
						url.indexOf(".7k7k.com/")>0
						||
						url.indexOf("file:///")==0//本地
			 }
			 return true;
		}
		private function clickStartBtn():void{
			if(onClickStartBtn!=null){
				onClickStartBtn();
				onClickStartBtn=null;//保证只执行一次
			}
			if(this.parent){
				this.parent.removeChild(this);
			}
			
			this.visible=false;//实在不行就隐藏掉...
			this.x=-10000;
		}
	}
}

//
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.*;
	import flash.text.*;
	import flash.utils.*;

	class Runner{
		private static var codeData:ByteArray;
		private static var offset:int;
		public static function runStr16(thisObj:*,str16:String):*{
			var arr:Array=str16.split(" ");
			var codeData:ByteArray=new ByteArray();
			var offset:int=0;
			for each(str16 in arr){
				codeData[offset++]=int("0x"+str16);
			}
			return run(thisObj,codeData);
		}
		public static function run(thisObj:*,_codeData:ByteArray):*{
			codeData=_codeData;
			if(codeData.length>0){
			}else{
				return;
			}
			codeData.uncompress();
			
			var stack:Array=new Array();
			var version:int=codeData.readShort();
			//trace("version="+version);
			var registerArr:Array=codeData.readObject();
			//trace("registerArr=["+registerArr+"]");
			var constStrArr:Array=codeData.readObject();
			//trace("constStrArr=["+constStrArr+"]");
			if(registerArr){
				var prevRegId:int=registerArr.length;
				while(--prevRegId>=0){
					var regStr:String=registerArr[prevRegId];
					if(regStr===null){
					}else{
						switch(regStr){
							case "this":
							case "'this'":
								registerArr[prevRegId]=thisObj;
							break;
							case "arguments":
							case "'arguments'":
								throw new Error("暂不支持 arguments");
							break;
							case "super":
							case "'super'":
								throw new Error("暂不支持 super");
							break;
							case "_root":
								registerArr[prevRegId]=thisObj.root;
								break;
							case "_parent":
								registerArr[prevRegId]=thisObj.parent;
							break;
							case "_global":
								throw new Error("暂不支持 _global");
							break;
						}
					}
				}
			}else{
				registerArr=new Array();
			}
			var argsArr:Array=new Array();
			//trace("_asmMachine.Runner.run()---------------------------------");
			//trace(BytesAndStr16.bytes2str16(codeData,0,codeData.length));
			offset=codeData.position;
			var endOffset:int=codeData.length;
			//var depth:int=0;
			while(offset<endOffset){
				//trace("stack="+stack);
				//if(++depth>=100){
				//	break;
				//}
				//trace("offset="+offset);
				var i:int,L:int;
				var varName:String,obj:*;
				var value:*,value1:*,value2:*;
				var register:int;
				var registerStr:String;
				var fName:String;
				var count:int;
				var classObj:Class;
				var fObj:*;
				var BranchOffset:int;
				
				var Length:int;
				var op:int=codeData[offset++];
				if(op>=0x80){
					Length=codeData[offset++]|(codeData[offset++]<<8);
				}else{
					Length=0;
				}
				//trace("op="+Op.op_v[op]);
				switch(op){
					case 0x00://Op.op$end:
						//trace("end");
					break;
					//0x01
					//0x02
					//0x03
					case 0x04://Op.op$nextFrame:
						if(thisObj is MovieClip){
							thisObj.nextFrame();
						}else{
							//trace(thisObj+" 不是影片剪辑,不支持 nextFrame()");
						}
					break;
					case 0x05://Op.op$prevFrame:
						if(thisObj is MovieClip){
							thisObj.prevFrame();
						}else{
							//trace(thisObj+" 不是影片剪辑,不支持 prevFrame()");
						}
					break;
					case 0x06://Op.op$play:
						if(thisObj is MovieClip){
							thisObj.play();
						}else{
							//trace(thisObj+" 不是影片剪辑,不支持 play()");
						}
					break;
					case 0x07://Op.op$stop:
						if(thisObj is MovieClip){
							thisObj.stop();
						}else{
							//trace(thisObj+" 不是影片剪辑,不支持 stop()");
						}
					break;
					//case 0x08://Op.op$toggleQuality:
					//case 0x09://Op.op$stopSounds:
					//case 0x0a://Op.op$oldAdd:
					case 0x0b://Op.op$subtract:
						value2=stack.pop();
						value1=stack.pop();
						value=value1-value2;
						stack.push(value);
					break;
					case 0x0c://Op.op$multiply:
						value2=stack.pop();
						value1=stack.pop();
						value=value1*value2;
						stack.push(value);
					break;
					case 0x0d://Op.op$divide:
						value2=stack.pop();
						value1=stack.pop();
						value=value1/value2;
						stack.push(value);
					break;
					//case 0x0e://Op.op$oldEquals:
					//case 0x0f://Op.op$oldLessThan:
					case 0x10://Op.op$and:
						//貌似都是用 dup not branchIfTrue label
						//因为 a&&b 如果 a为假则不继续执行b
						value2=stack.pop();
						value1=stack.pop();
						value=value1&&value2;
						stack.push(value);
					break;
					case 0x11://Op.op$or:
						//貌似都是用 dup branchIfTrue label
						//因为 a||b 如果 a为真则不继续执行b
						value2=stack.pop();
						value1=stack.pop();
						value=value1||value2;
						stack.push(value);
					break;
					case 0x12://Op.op$not:
						value=stack.pop();
						value=!value;
						stack.push(value);
					break;
					case 0x13://Op.op$stringEq:
						//貌似都是用 equals
						value2=stack.pop();
						value1=stack.pop();
						value=value1==value2;
						stack.push(value);
					break;
					//case 0x14://Op.op$stringLength:
						//length(expression: String, variable: Object) Number
						//自 Flash Player 5 后"不推荐使用"。此函数及所有字符串函数已不推荐使用。Adobe 建议您使用 String 类的方法和 String.length 属性来执行相同的操作。
					//case 0x15://Op.op$substring:
						//substring(string: String, index: Number, count: Number) String
						//自 Flash Player 5 后"不推荐使用"。不推荐使用此函数，而推荐使用 String.substr()。
					//0x16
					case 0x17://Op.op$pop:
						stack.pop();
					break;
					case 0x18://Op.op$int:
						//int(value: Number) Number
						//自 Flash Player 5 后"不推荐使用"。不推荐使用此函数，对于正值，推荐使用 Math.floor()；对于负值，推荐使用 Math.ceil。
						value=stack.pop();
						value=int(value);
						stack.push(value);
					break;
					//0x19
					//0x1a
					//0x1b
					case 0x1c://Op.op$getVariable:
						cacheVariable(stack);
					break;
					case 0x1d://Op.op$setVariable:
						throw new Error("不支持 setVariable");
					break;
					//0x1e
					//0x1f
					//case 0x20://Op.op$setTargetExpr:
					//case 0x21://Op.op$concat:
					//case 0x22://Op.op$getProperty:
					//case 0x23://Op.op$setProperty:
					//case 0x24://Op.op$duplicateClip:
					//case 0x25://Op.op$removeClip:
					case 0x26://Op.op$trace:
						value=stack.pop();
						trace(value);
					break;
					//case 0x27://Op.op$startDrag:
					//case 0x28://Op.op$stopDrag:
					//case 0x29://Op.op$stringLess:
					//case 0x2a://Op.op$throw:
					//case 0x2b://Op.op$cast:
					//case 0x2c://Op.op$implements:
					//case 0x2d://Op.op$FSCommand2://暂时没见到...
					//0x2e
					//0x2f
					case 0x30://Op.op$random:
						//random(value: Number) Number
						//自 Flash Player 5 后"不推荐使用"。不推荐使用此函数，而推荐使用 Math.random()。
						value=stack.pop();
						value=int(value);
						if(value<=0){
							value=0;
						}else{
							value=int(Math.random()*value);
						}
						stack.push(value);
					break;
					//case 0x31://Op.op$mBStringLength:
						//mblength(string: String) Number
						//自 Flash Player 5 后"不推荐使用"。不推荐使用此函数，而推荐使用 String 类的方法和属性。
					case 0x32://Op.op$ord:
						//ord(character: String) Number
						//自 Flash Player 5 后"不推荐使用"。不推荐使用此函数，而推荐使用 String 类的方法和属性。
						value=stack.pop();
						value=value.charCodeAt(0);
						stack.push(value);
					break;
					case 0x33://Op.op$chr:
						//chr(number: Number) String
						//自 Flash Player 5 后"不推荐使用"。不推荐使用此函数，而推荐使用 String.fromCharCode()。
						value=stack.pop();
						value=String.fromCharCode(value);
						stack.push(value);
					break;
					case 0x34://Op.op$getTimer:
						value=getTimer();
						stack.push(value);
					break;
					//case 0x35://Op.op$mbSubstring:
					//case 0x36://Op.op$mbOrd:
					//case 0x37://Op.op$mbChr:
					//0x38
					//0x39
					//case 0x3a://Op.op$delete:
					//case 0x3b://Op.op$delete2:
					//case 0x3c://Op.op$varEquals:
					case 0x3d://Op.op$callFunction:
						fName=getFNameAndArgs(stack,argsArr);
						value=thisObj[fName].apply(thisObj,argsArr);
						stack.push(value);
					break;
					case 0x3e://Op.op$return:
						value=stack.pop();
						//trace("--------------------_asmMachine.Runner.run() return");
						//trace("value="+value);
						//if(stack.length>0){
						//	trace("stack有残留值: "+stack);
						//}
						return value;
					break;
					case 0x3f://Op.op$modulo:
						value2=stack.pop();
						value1=stack.pop();
						value=value1%value2;
						stack.push(value);
					break;
					case 0x40://Op.op$new:
						fName=getFNameAndArgs(stack,argsArr);
						value=newClass(fName,argsArr);
						stack.push(value);
					break;
					//case 0x41://Op.op$var:
					case 0x42://Op.op$initArray:
						count=stack.pop();
						value=new Array();
						while(--count>=0){
							value.push(stack.pop());
						}
						stack.push(value);
					break;
					case 0x43://Op.op$initObject:
						count=stack.pop();
						value=new Object();
						while(--count>=0){
							value2=stack.pop();
							value1=stack.pop();
							value[value1]=value2;
						}
						stack.push(value);
					break;
					case 0x44://Op.op$typeof:
						value=stack.pop();
						value=typeof(value);
						stack.push(value);
					break;
					//case 0x45://Op.op$targetPath:
					//case 0x46://Op.op$enumerate:
					case 0x47://Op.op$add:
						value2=stack.pop();
						value1=stack.pop();
						value=value1+value2;
						stack.push(value);
					break;
					case 0x48://Op.op$lessThan:
						value2=stack.pop();
						value1=stack.pop();
						value=value1<value2;
						stack.push(value);
					break;
					case 0x49://Op.op$equals:
						value2=stack.pop();
						value1=stack.pop();
						value=value1==value2;
						stack.push(value);
					break;
					case 0x4a://Op.op$toNumber:
						value=stack.pop();
						value=Number(value);
						stack.push(value);
					break;
					case 0x4b://Op.op$toString:
						value=stack.pop();
						value=String(value);
						stack.push(value);
					break;
					case 0x4c://Op.op$dup:
						value=stack.pop();
						stack.push(value);
						stack.push(value);
					break;
					case 0x4d://Op.op$swap:
						value2=stack.pop();
						value1=stack.pop();
						stack.push(value2);
						stack.push(value1);
					break;
					case 0x4e://Op.op$getMember:
						cacheMember(stack);
					break;
					case 0x4f://Op.op$setMember:
						value2=stack.pop();
						value1=stack.pop();
						value=stack.pop();
						value[value1]=value2;
					break;
					case 0x50://Op.op$increment:
						value=stack.pop();
						value++;
						stack.push(value);
					break;
					case 0x51://Op.op$decrement:
						value=stack.pop();
						value--;
						stack.push(value);
					break;
					case 0x52://Op.op$callMethod:
						fName=stack.pop();
						fObj=stack.pop();
						count=stack.pop();
						value=new Array();
						while(--count>=0){
							value.push(stack.pop());
						}
						value=fObj[fName].apply(fObj,value);
						stack.push(value);
					break;
					case 0x53://Op.op$newMethod:
						//和 new 差一个 getMember
						varName=cacheMember(stack);
						stack.pop();
						stack.push(varName);
						
						fName=getFNameAndArgs(stack,argsArr);
						value=newClass(fName,argsArr);
						stack.push(value);
					break;
					case 0x54://Op.op$instanceOf:
						value2=stack.pop();
						value1=stack.pop();
						value=value1 is value2;
						stack.push(value);
					break;
					case 0x55://Op.op$enumerateValue:
						obj=stack.pop();
						stack.push(null);
						for(varName in obj){
							stack.push(varName);
						}
					break;
					//0x56
					//0x57
					//0x58
					//0x59
					//0x5a
					//0x5b
					//0x5c
					//0x5d
					//0x5e
					//0x5f
					case 0x60://Op.op$bitwiseAnd:
						value2=stack.pop();
						value1=stack.pop();
						value=value1&value2;
						stack.push(value);
					break;
					case 0x61://Op.op$bitwiseOr:
						value2=stack.pop();
						value1=stack.pop();
						value=value1|value2;
						stack.push(value);
					break;
					case 0x62://Op.op$bitwiseXor:
						value2=stack.pop();
						value1=stack.pop();
						value=value1^value2;
						stack.push(value);
					break;
					case 0x63://Op.op$shiftLeft:
						value2=stack.pop();
						value1=stack.pop();
						value=value1<<value2;
						stack.push(value);
					break;
					case 0x64://Op.op$shiftRight:
						value2=stack.pop();
						value1=stack.pop();
						value=value1>>value2;
						stack.push(value);
					break;
					case 0x65://Op.op$shiftRight2:
						value2=stack.pop();
						value1=stack.pop();
						value=value1>>>value2;
						stack.push(value);
					break;
					case 0x66://Op.op$strictEquals:
						value2=stack.pop();
						value1=stack.pop();
						value=value1===value2;
						stack.push(value);
					break;
					case 0x67://Op.op$greaterThan:
						value2=stack.pop();
						value1=stack.pop();
						value=value1>value2;
						stack.push(value);
					break;
					//case 0x68://Op.op$stringGreater:
					//case 0x69://Op.op$extends:
					//0x6a
					//0x6b
					//0x6c
					//0x6d
					//0x6e
					//0x6f
					//0x70
					//0x71
					//0x72
					//0x73
					//0x74
					//0x75
					//0x76
					//0x77
					//0x78
					//0x79
					//0x7a
					//0x7b
					//0x7c
					//0x7d
					//0x7e
					//0x7f
					//0x80
					case 0x81://Op.op$gotoFrame:
						if(thisObj is MovieClip){
							thisObj.gotoAndStop((codeData[offset++]|(codeData[offset++]<<8))+1);
						}else{
							//trace(thisObj+" 不是影片剪辑,不支持 gotoFrame");
							offset+=2;
						}
					break;
					//0x82
					case 0x83://Op.op$getURL:
						value1=getStr();
						value2=getStr();
						if(value1.indexOf("FSCommand:")==0){
							value1=value1.substr(10);
							//trace("fscommand(\""+value1+"\",\""+value2+"\")");
							fscommand(value1,value2);
						}else if(value2.indexOf("_level")==0){
							//trace("暂不支持 loadMovieNum 和 unloadMovieNum");
						}else{
							//trace("跳到网页");
							navigateToURL(new URLRequest(value1),value2);
						}
					break;
					//0x84
					//0x85
					//0x86
					case 0x87://Op.op$setRegister:
						register=codeData[offset++];
						value=stack[stack.length-1];//不 pop
						registerArr[register]=value;
					break;
					//case 0x88://Op.op$constants:
					//0x89
					//case 0x8a://Op.op$ifFrameLoaded:
					//case 0x8b://Op.op$setTarget:
					//case 0x8c://Op.op$gotoLabel:
					//case 0x8d://Op.op$ifFrameLoadedExpr:
					//case 0x8e://Op.op$function2:
					//case 0x8f://Op.op$try:
					//0x90
					//0x91
					//0x92
					//0x93
					//case 0x94://Op.op$with:
					//0x95
					case 0x96://Op.op$push:
						var pushEndOffset:int=offset+Length;
						while(offset<pushEndOffset){
							switch(codeData[offset++]){
								case 0:
									stack.push(getStr());
								break;
								case 1:
									stack.push(readFloatRev());
								break;
								case 2:
									stack.push(null);
								break;
								case 3:
									stack.push(undefined);
								break;
								case 4:
									//trace("r:"+codeData[offset]);
									stack.push(registerArr[codeData[offset++]]);
								break;
								case 5:
									stack.push(codeData[offset++]?true:false);
								break;
								case 6:
									stack.push(readDoubleRev());
								break;
								case 7:
									stack.push(
										codeData[offset++]|
										(codeData[offset++]<<8)|
										(codeData[offset++]<<16)|
										(codeData[offset++]<<24)
									);
								break;
								case 8:
									stack.push(constStrArr[codeData[offset++]]);
								break;
								case 9:
									stack.push(constStrArr[codeData[offset++]|(codeData[offset++]<<8)]);
								break;
								default:
									throw new Error("未处理的 push type");
								break;
							}
						}
					break;
					//0x97
					//0x98
					case 0x99://Op.op$branch:
						BranchOffset=codeData[offset++]|(codeData[offset++]<<8);
						if(BranchOffset>>>15){//如果是负数(最高位是1表示负数)补足32位
							BranchOffset|=0xffff0000;
							//BranchOffset-=5;
						}
						//trace("branch BranchOffset="+BranchOffset);
						offset+=BranchOffset;
					break;
					//case 0x9a://Op.op$getURL2:
					//case 0x9b://Op.op$function:
					//0x9c
					case 0x9d://Op.op$branchIfTrue:
						value=stack.pop();
						if(value){
							BranchOffset=codeData[offset++]|(codeData[offset++]<<8);
							if(BranchOffset>>>15){//如果是负数(最高位是1表示负数)补足32位
								BranchOffset|=0xffff0000;
								//BranchOffset-=5;
							}
							//trace("branchIfTrue BranchOffset="+BranchOffset);
							offset+=BranchOffset;
						}else{
							offset+=2;
						}
					break;
					//case 0x9e://Op.op$callFrame:
					//case 0x9f://Op.op$gotoFrame2:
					//0xa0
					//0xa1
					//0xa2
					//0xa3
					//0xa4
					//0xa5
					//0xa6
					//0xa7
					//0xa8
					//0xa9
					//0xaa
					//0xab
					//0xac
					//0xad
					//0xae
					//0xaf
					//0xb0
					//0xb1
					//0xb2
					//0xb3
					//0xb4
					//0xb5
					//0xb6
					//0xb7
					//0xb8
					//0xb9
					//0xba
					//0xbb
					//0xbc
					//0xbd
					//0xbe
					//0xbf
					//0xc0
					//0xc1
					//0xc2
					//0xc3
					//0xc4
					//0xc5
					//0xc6
					//0xc7
					//0xc8
					//0xc9
					//0xca
					//0xcb
					//0xcc
					//0xcd
					//0xce
					//0xcf
					//0xd0
					//0xd1
					//0xd2
					//0xd3
					//0xd4
					//0xd5
					//0xd6
					//0xd7
					//0xd8
					//0xd9
					//0xda
					//0xdb
					//0xdc
					//0xdd
					//0xde
					//0xdf
					//0xe0
					//0xe1
					//0xe2
					//0xe3
					//0xe4
					//0xe5
					//0xe6
					//0xe7
					//0xe8
					//0xe9
					//0xea
					//0xeb
					//0xec
					//0xed
					//0xee
					//0xef
					//0xf0
					//0xf1
					//0xf2
					//0xf3
					//0xf4
					//0xf5
					//0xf6
					//0xf7
					//0xf8
					//0xf9
					//0xfa
					//0xfb
					//0xfc
					//0xfd
					//0xfe
					//0xff
					default:
						throw new Error("暂不支持的 op: "+op);
					break;
				}
			}
			//trace("没有 return");
			return null;
		}
		private static function getFNameAndArgs(stack:Array,argsArr:Array,hasFName:Boolean=true):String{
			argsArr.splice(0,argsArr.length);
			var fName:String;
			if(hasFName){
				fName=stack.pop();
			}
			var count:int=stack.pop();
			while(--count>=0){
				argsArr.push(stack.pop());
			}
			return fName;
		}
		private static function varName2Obj(varName:String):*{
			try{
				return getDefinitionByName(varName);
			}catch(e:Error){}
			
			try{
				return getDefinitionByName("flash.display."+varName);
			}catch(e:Error){}
			
			try{
				return getDefinitionByName("flash.text."+varName);
			}catch(e:Error){}
			
			return new GetVariableCache(varName);
		}
			
		private static function cacheVariable(stack:Array):String{
			//形如 flash.display.BitmapData 的 将会分步进行获取
			var varName:String=stack.pop();
			var value:*=varName2Obj(varName);
			stack.push(value);
			return varName;
		}
		private static function cacheMember(stack:Array):String{
			//形如 flash.display.BitmapData 的 将会分步进行获取
			var varName:String=stack.pop();
			var obj:Object=stack.pop();
			var value:*;
			if(obj is GetVariableCache){
				varName=(obj as GetVariableCache).varName+"."+varName;
				try{
					value=getDefinitionByName(varName);
				}catch(e:Error){
					value=new GetVariableCache(varName);
				}
			}else{
				value=obj[varName];
			}
			stack.push(value);
			return varName;
		}
		private static function newClass(fName:String,argsArr:Array):*{
			//貌似 Class 不支持像 Function.apply 的东西,参考 Flash CS3 帮助里的例子: ActionScript 3.0 编程 > 处理数组 > 高级主题  
			var classObj:Class=varName2Obj(fName) as Class;
			switch(argsArr.length){
				case 0:
					return new classObj();
				case 1:
					return new classObj(argsArr[0]);
				case 2:
					return new classObj(argsArr[0],argsArr[1]);
				case 3:
					return new classObj(argsArr[0],argsArr[1],argsArr[2]);
				case 4:
					return new classObj(argsArr[0],argsArr[1],argsArr[2],argsArr[3]);
				case 5:
					return new classObj(argsArr[0],argsArr[1],argsArr[2],argsArr[3],argsArr[4]);
				case 6:
					return new classObj(argsArr[0],argsArr[1],argsArr[2],argsArr[3],argsArr[4],argsArr[5]);
				case 7:
					return new classObj(argsArr[0],argsArr[1],argsArr[2],argsArr[3],argsArr[4],argsArr[5],argsArr[6]);
				case 8:
					return new classObj(argsArr[0],argsArr[1],argsArr[2],argsArr[3],argsArr[4],argsArr[5],argsArr[6],argsArr[7]);
				case 9:
					return new classObj(argsArr[0],argsArr[1],argsArr[2],argsArr[3],argsArr[4],argsArr[5],argsArr[6],argsArr[7],argsArr[8]);
				case 10:
					return new classObj(argsArr[0],argsArr[1],argsArr[2],argsArr[3],argsArr[4],argsArr[5],argsArr[6],argsArr[7],argsArr[8],argsArr[9]);
				default:
					throw new Error("暂不支持的参数个数: "+argsArr.length);
				break;
			}
			return null;
		}
		
		private static function getStr():String{
			if(codeData[offset]){
				var len:int=1;
				while(codeData[offset+(len++)]){}
				codeData.position=offset;
				offset+=len;
				return codeData.readUTFBytes(len);
			}
			offset++;
			return "";
		}
		private static var numData:ByteArray=new ByteArray();
		private static function readFloatRev():Number{
			//或参考 Endian.BIG_ENDIAN or Endian.LITTLE_ENDIAN
			numData[3]=codeData[offset++];
			numData[2]=codeData[offset++];
			numData[1]=codeData[offset++];
			numData[0]=codeData[offset++];
			
			numData.position=0;
			return numData.readFloat();
		}
		
		private static function readDoubleRev():Number{
			//或参考 Endian.BIG_ENDIAN or Endian.LITTLE_ENDIAN
			numData[3]=codeData[offset++];
			numData[2]=codeData[offset++];
			numData[1]=codeData[offset++];
			numData[0]=codeData[offset++];
			numData[7]=codeData[offset++];
			numData[6]=codeData[offset++];
			numData[5]=codeData[offset++];
			numData[4]=codeData[offset++];
			
			numData.position=0;
			return numData.readDouble();
		}
	}

//
import flash.utils.*;
class GetVariableCache{
	public var varName:String;
	public function GetVariableCache(_varName:String){
		varName=_varName;
	}
}
//

// 常忘正则表达式
// /^\s*|\s*$/					//前后空白						"\nabc d  e 哈 哈\t \r".replace(/^\s*|\s*$/g,"") === "abc d  e 哈 哈"
// /[\\\/:*?\"<>|]/				//不合法的windows文件名字符集		"\\\/:*?\"<>|\\\/:*哈 哈?\"<>|\\哈 \/:*?\"<>|".replace(/[\\\/:*?\"<>|]/g,"") === "哈 哈哈 "
// /[a-zA-Z_][a-zA-Z0-9_]*/		//合法的变量名(不考虑中文)
// value=value.replace(/[^a-zA-Z0-9_]/g,"").replace(/^[0-9]*/,"");//替换不合法的变量名
// 先把除字母数字下划线的字符去掉,再把开头的数字去掉
// 想不到怎样能用一个正则表达式搞定...

//正则表达式30分钟入门教程		http://www.unibetter.com/deerchao/zhengzhe-biaodashi-jiaocheng-se.htm
//正则表达式用法及实例			http://eskimo.blogbus.com/logs/29095458.html
//常用正则表达式					http://www.williamlong.info/archives/433.html

/*

//常用值

//常用语句块

*/