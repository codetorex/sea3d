package awayphysics.dynamics.vehicle {
	import AWPC_Run.CModule;
	import AWPC_Run.addVehicleWheelInC;
	import AWPC_Run.createVehicleInC;
	import AWPC_Run.disposeVehicleInC;
	
	import away3d.containers.ObjectContainer3D;
	
	import awayphysics.AWPBase;
	import awayphysics.dynamics.AWPRigidBody;
	import awayphysics.math.AWPVector3;
	
	import flash.geom.Vector3D;

	/**
	 * create the raycast vehicle
	 * refer to https://docs.google.com/document/edit?id=18edpOwtGgCwNyvakS78jxMajCuezotCU_0iezcwiFQc
	 */
	public class AWPRaycastVehicle extends AWPBase {
		private var m_chassisBody : AWPRigidBody;
		private var m_wheelInfo : Vector.<AWPWheelInfo>;

		public function AWPRaycastVehicle(tuning : AWPVehicleTuning, chassis : AWPRigidBody) {
			pointer = createVehicleInC(chassis.pointer,tuning.suspensionStiffness,tuning.suspensionCompression,tuning.suspensionDamping,tuning.maxSuspensionTravelCm,tuning.frictionSlip,tuning.maxSuspensionForce);

			m_chassisBody = chassis;
			m_wheelInfo = new Vector.<AWPWheelInfo>();
		}

		public function getRigidBody() : AWPRigidBody {
			return m_chassisBody;
		}

		public function getNumWheels() : int {
			return m_wheelInfo.length;
		}

		public function getWheelInfo(index : int) : AWPWheelInfo {
			if (index < m_wheelInfo.length) {
				return m_wheelInfo[index];
			}
			return null;
		}

		public function addWheel(_skin : ObjectContainer3D, connectionPointCS0 : Vector3D, wheelDirectionCS0 : Vector3D, wheelAxleCS : Vector3D, suspensionRestLength : Number, wheelRadius : Number, tuning : AWPVehicleTuning, isFrontWheel : Boolean) : void {
			var vec1:AWPVector3 = new AWPVector3();
			vec1.sv3d = connectionPointCS0;
			var vec2:AWPVector3 = new AWPVector3();
			vec2.v3d = wheelDirectionCS0;
			var vec3:AWPVector3 = new AWPVector3();
			vec3.v3d = wheelAxleCS;
			var wp : uint = addVehicleWheelInC(pointer, vec1.pointer, vec2.pointer, vec3.pointer, tuning.suspensionStiffness,tuning.suspensionCompression,tuning.suspensionDamping,tuning.maxSuspensionTravelCm,tuning.frictionSlip,tuning.maxSuspensionForce,suspensionRestLength / _scaling, wheelRadius / _scaling, (isFrontWheel) ? 1 : 0);
			CModule.free(vec1.pointer);
			CModule.free(vec2.pointer);
			CModule.free(vec3.pointer);
			if (m_wheelInfo.length > 0) {
				var num : int = 0;
				for (var i : int = m_wheelInfo.length - 1; i >= 0; i-- ) {
					num += 1;
					m_wheelInfo[i] = new AWPWheelInfo(wp - 284 * num, m_wheelInfo[i].skin);
				}
			}

			m_wheelInfo.push(new AWPWheelInfo(wp, _skin));
		}

		public function applyEngineForce(force : Number, wheelIndex : int) : void {
			m_wheelInfo[wheelIndex].engineForce = force;
		}

		public function setBrake(brake : Number, wheelIndex : int) : void {
			m_wheelInfo[wheelIndex].brake = brake;
		}

		public function setSteeringValue(steering : Number, wheelIndex : int) : void {
			m_wheelInfo[wheelIndex].steering = steering;
		}

		public function getSteeringValue(wheelIndex : int) : Number {
			return m_wheelInfo[wheelIndex].steering;
		}

		public function updateWheelsTransform() : void {
			for each (var wheel:AWPWheelInfo in m_wheelInfo) {
				wheel.updateTransform();
			}
		}
		
		public function dispose():void {
			if (!_cleanup) {
				_cleanup = true;
				disposeVehicleInC(pointer);
			}
		}
	}
}