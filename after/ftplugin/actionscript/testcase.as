package {
	import flash.xml.XMLNode;
	import flash.display.*;
	import flash.geom.*;
	import flash.text.*;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import ui.Map;
	import ui.Background;
	import ui.TextBoard;
	import ui.VText;
	import flash.utils.setTimeout;
	import com.robertpenner.easing.Quad;
	import flash.external.ExternalInterface;

	[SWF(width="1920",height="1080",frameRate="30",backgroundColor="#ffffff")]
	public class WardInfo extends MovieClip {
		private var settingsUrl : String = 'wardInfoSettings.xml';
		private var interval : uint; 
		private var update_timer : Timer;
		private var map : Map;
		private var otherBoard : TextBoard;
		private var nurseBoard : TextBoard;
		private var consulationBoard : TextBoard;
		private var outHospital : VText;
		private var inHospital : VText;
		private var nurse : VText;
		private var dVisit : VText;
		private var op : VText;
		private var mapDataUrl : String;
		private var mapDataLdr : URLLoader;
		private var noteDataUrl : String;
		private var noteDataLdr : URLLoader;
		private var patDataUrl : String;
		private var patDataLdr : URLLoader;
		private var nurseDataUrl : String;
		private var nurseDataLdr : URLLoader;
		private var visitDataUrl : String;
		private var visitDataLdr : URLLoader;
		private var opDataUrl : String;
		private var opDataLdr : URLLoader;
		private var prevXml : XML = null;
		private var prevPatXml : XML = null;
		private var prevNurseXml : XML = null;
		private var prevVisitXml : XML = null;
		private var prevOpXml : XML = null;

		public function WardInfo():void {
			patDataLdr = new URLLoader();
			patDataLdr.addEventListener(Event.COMPLETE, onPatDataLoaded);

			nurseDataLdr = new URLLoader();
			nurseDataLdr.addEventListener(Event.COMPLETE, onNurseDataLoaded);

			visitDataLdr = new URLLoader();
			visitDataLdr.addEventListener(Event.COMPLETE, onVisitDataLoaded);

			opDataLdr = new URLLoader();
			opDataLdr.addEventListener(Event.COMPLETE, onOpDataLoaded);

			mapDataLdr = new URLLoader();
			mapDataLdr.addEventListener(Event.COMPLETE, onMapDataLoaded);

			noteDataLdr = new URLLoader();
			noteDataLdr.addEventListener(Event.COMPLETE, onNoteDataLoaded);

			var settingsLdr : URLLoader = new URLLoader();
			settingsLdr.addEventListener(Event.COMPLETE, onSettingsLoaded);
			settingsLdr.load(new URLRequest(settingsUrl));
			addChild(new Background());
			addChild(new WardInfoBackgroundAsset());
		}

		private function onSettingsLoaded(e : Event) : void {
			var xml : XML = new XML(e.target.data);
			var refreshInterval : Number = Number(xml.refreshInterval.toString());
			mapDataUrl = xml.mapDataUrl.toString();
			noteDataUrl = xml.noteDataUrl.toString();
			patDataUrl = xml.patientDataUrl.toString();
			nurseDataUrl = xml.nurseDataUrl.toString();
			visitDataUrl = xml.visitDataUrl.toString();
			opDataUrl = xml.operationDataUrl.toString();
			var floor : int = int(xml.floor.toString());

			map = new Map(floor);
			map.x = 10;
			map.y = 280;
			addChild(map);

			nurseBoard = new TextBoard();
			nurseBoard.x = 1435;
			nurseBoard.y = 756;
			addChild(nurseBoard)

			consulationBoard = new TextBoard();
			consulationBoard.x =1435;
			consulationBoard.y =872;
			addChild(consulationBoard);

			otherBoard = new TextBoard();
			otherBoard.x = 1435;
			otherBoard.y = 992;
			addChild(otherBoard);

			outHospital = new VText([0]);
			outHospital.x = 1578;
			outHospital.y = 197;
			addChild(outHospital);

			inHospital = new VText([0]);
			inHospital.x = 1578;
			inHospital.y = 266;
			addChild(inHospital);

			nurse = new VText([0, 200]);
			nurse.x = 1446;
			nurse.y = 396;
			addChild(nurse);

			dVisit = new VText([0, 200]);
			dVisit.x = 1446;
			dVisit.y = 516;
			addChild(dVisit);

			op = new VText([0, 200]);
			op.x = 1446;
			op.y = 634;
			addChild(op);

			this.update_timer = new Timer(refreshInterval*1000);
			this.update_timer.addEventListener(TimerEvent.TIMER, this.update);
			this.update_timer.start();
			update();
		}

		private function update(evt:Event = null) : void {
			mapDataLdr.load(new URLRequest(mapDataUrl));
			noteDataLdr.load(new URLRequest(noteDataUrl));
			patDataLdr.load(new URLRequest(patDataUrl));
			nurseDataLdr.load(new URLRequest(nurseDataUrl));
			visitDataLdr.load(new URLRequest(visitDataUrl));
			opDataLdr.load(new URLRequest(opDataUrl));
		}

		private function onPatDataLoaded(e:Event) : void {
			var xml : XML = new XML(e.target.data);
			if (!prevPatXml || prevPatXml != xml) {
				var inData : Array = [];
				var outData : Array = [];
				for each(var pat : XML in xml.patient) {
					if (pat.status == '出院')
						outData.push([pat.ward.toString()]);
					else if (pat.status == '入院')
						inData.push([pat.ward.toString()]);
				}
				outHospital.data = outData;
				inHospital.data = inData;
			}
			prevPatXml = xml;
		}

		private function onNurseDataLoaded(e:Event) : void {
			var xml : XML = new XML(e.target.data);
			if (!prevNurseXml || prevNurseXml != xml) {
				var data : Array = [];
				for each(var n : XML in xml.nurse) {
					data.push([n.next.toString(), n.nextEnterTime.toString()]);
				}
				nurse.data = data;
			}
			prevNurseXml = xml;
		}

		private function onVisitDataLoaded(e:Event) : void {
			var xml : XML = new XML(e.target.data);
			if (!prevVisitXml || prevVisitXml != xml) {
				var data : Array = [];
				for each(var v : XML in xml.visit) {
					data.push([v.doctor.toString(), v.time.toString()]);
				}
				dVisit.data = data;
			}
			prevVisitXml = xml;
		}

		private function onOpDataLoaded(e:Event) : void {
			var xml : XML = new XML(e.target.data);
			if (!prevOpXml || prevOpXml != xml) {
				var data : Array = [];
				for each(var o : XML in xml.operation) {
					data.push([o.opDate.toString(), o.patName.toString()]);
				}
				op.data = data;
			}
			prevOpXml = xml;
		}


		private function onNoteDataLoaded(e:Event) : void {
			var xml : XML = new XML(e.target.data);
			otherBoard.data = xml.other.toString();
			nurseBoard.data = xml.nurse.toString();
			consulationBoard.data = xml.consulation.toString();
		}

		private function onMapDataLoaded(e:Event) : void {
			var xml : XML = new XML(e.target.data);
			if (!prevXml || xml != prevXml) {
				var data : Object = {}
				for each(var ward : XML in xml.ward) {
					data[ward.id.toString()] = ward.level.toString();
				}
				map.data = data;
			}
			prevXml = xml;
		}
	}
}

