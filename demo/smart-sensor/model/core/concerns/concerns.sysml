// Smart Sensor concern register.
//
// Per methodology §1.4.6 and §4.3.2, each stakeholder concern is a
// `concern def` (a specialised requirement). Concerns persist across
// iterations. Stories `frame` them. The frame relation is n:m: one
// concern can be addressed by several stories, and one story can
// address several concerns.

package SmartSensor_Concerns {

    private import SmartSensor_Stakeholders::*;
    private import SmartSensor_Context::*;

    concern def StableMonitoring {
        subject system    : SmartSensor_System;
        stakeholder ops   : Operator;
        doc /* Operations need uninterrupted, accurate readings from
               the deployment site so that conditions can be
               monitored without manual intervention. */
    }

    concern def AlertResponseTime {
        subject system    : SmartSensor_System;
        stakeholder ops   : Operator;
        doc /* When an alert is raised, the operator needs short
               time-to-acknowledge so the alert queue does not
               accumulate during an incident. */
    }

    concern def DeviceServiceability {
        subject system    : SmartSensor_System;
        stakeholder maint : MaintenanceTechnician;
        doc /* The maintenance technician needs to install,
               calibrate, and replace devices in the field
               without specialist tooling. */
    }

    concern def DataRetentionCompliance {
        subject system    : SmartSensor_System;
        stakeholder reg   : Regulator;
        doc /* Industry regulations require sensor readings to be
               retained for a defined period and to be tamper-evident
               in the cloud-side data store. */
    }
}
