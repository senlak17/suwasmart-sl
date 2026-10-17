import from services.queueService { get_staff_appointments, update_doctor_queue, get_lab_tests, update_lab_test }
import from services.queueService { triage_symptoms, get_chat_messages }
import ".styles.global.css";
import from "@jac/runtime" { Router, Routes, Route }
import from .components.HospitalQueue { HospitalQueue }
import from .components.StaffWorkflows { StaffWorkflows }


def:pub app() -> JsxElement {
    return <Router><Routes><Route path="/" element={<HospitalQueue />} /><Route path="/staff" element={<StaffWorkflows />} /></Routes></Router>;
}
