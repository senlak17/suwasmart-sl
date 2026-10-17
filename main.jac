import from services.queueService { get_queue, create_booking, Hospital, Appointment }
import ".styles.global.css";
import from "@jac/runtime" { Router, Routes, Route }
import from .components.HospitalQueue { HospitalQueue }

def:pub app() -> JsxElement {
    return <Router><Routes><Route path="/" element={<HospitalQueue />} /></Routes></Router>;
}
