// Smart Sensor Base Architecture (§2).
//
// Per methodology §2.1 and §2.6, this captures architectural and
// technical decisions that pre-existed the project and constrain
// its work from outside it. The Smart Sensor project did not pick
// the ESP32 platform or the MQTT broker, those choices were made
// by the parent product line in 2024.

library package <SS_BA> SmartSensor_BaseArchitecture {

    private import ScalarValues::*;

    // The reference Wi-Fi MCU platform every device in the line uses.
    part def ESP32_MCU {
        attribute partNumber  : String  = "ESP32-WROOM-32E";
        attribute flashKB     : Natural = 4096;
        attribute ramKB       : Natural = 520;
        attribute hasWiFi     : Boolean = true;

        port readingsOut : ReadingsTxPort;
        port mgmt        : MgmtPort;
    }

    // Immutable Base Architecture constraint over the platform. Per
    // §2.6 rule 2, this constraint shall not be redefined with a
    // weaker form by any specialising part.
    requirement def MemoryConstraint {
        subject mcu : ESP32_MCU;
        doc /* Firmware image plus runtime data shall fit within
               mcu.flashKB KiB of program flash. */
    }

    // The cloud-side MQTT broker that receives readings.
    part def MQTT_Broker {
        attribute deployment  : String  = "managed cloud";
        attribute protocol    : String  = "MQTT 5.0";
        attribute tlsRequired : Boolean = true;
        port ingest          : MqttIngestPort;
    }

    // Placeholder port type declarations.
    port def ReadingsTxPort;
    port def MgmtPort;
    port def MqttIngestPort;
}
