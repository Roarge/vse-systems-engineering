// Smart Sensor System Context (§3).
//
// Per methodology §3, this composite owns the system part and every
// external actor with their interfaces and item flows.

package SmartSensor_Context {

    private import SmartSensor_BaseArchitecture::*;
    private import SmartSensor_Stakeholders::*;
    private import SmartSensor_Domain::*;

    // The Smart Sensor system, specialising the ESP32 platform from
    // the Base Architecture.
    part def SmartSensor_System :> ESP32_MCU {
        port operatorUI  : OperatorUIPort;
        port maintenance : MaintenancePort;
        port cloud       : CloudIngestPort;
    }

    // External system actor: the operator dashboard delivered by
    // the cloud service. The Operator interacts with the system
    // through this dashboard.
    part def CloudDashboard {
        port operatorPort : DashboardPort;
        port mqttIngest   : MqttIngestPort;
    }

    // Environmental effect: the deployment-site climate the device
    // measures.
    part def AmbientClimate {
        attribute siteTemperature : TemperatureCelsius;
        attribute siteHumidity    : RelativeHumidity;
    }

    // Reusable interface types.
    interface def OperatorUIInterface {
        end systemSide   : OperatorUIPort;
        end operatorSide : DashboardPort;
    }

    interface def CloudInterface {
        end deviceSide : CloudIngestPort;
        end cloudSide  : MqttIngestPort;
    }

    // Composite System Context part.
    part def SmartSensor_Context_Composite {
        part system   : SmartSensor_System;
        part operator : Operator;
        part maint    : MaintenanceTechnician;
        part dashboard: CloudDashboard;
        part ambient  : AmbientClimate;

        interface ui : OperatorUIInterface
            connect system.operatorUI to dashboard.operatorPort;
    }

    // Placeholder port types used at the system boundary.
    port def OperatorUIPort;
    port def MaintenancePort;
    port def CloudIngestPort;
    port def DashboardPort;
}
