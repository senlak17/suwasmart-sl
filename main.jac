import from services.queueService { get_staff_appointments, update_doctor_queue, get_lab_tests, update_lab_test }
import from services.queueService { triage_symptoms, get_chat_messages }
import from services.accountService { submit_staff_application }
import ".styles.global.css";
import from "@jac/runtime" { Router, Routes, Route }
import from .components.AccountPortal { AccountPortal }
import from .components.HospitalQueue { HospitalQueue }
import from .components.HealthHistory { HealthHistory }
import from .components.StaffWorkflows { StaffWorkflows }


def:pub app() -> JsxElement {
    return <Router><Routes><Route path="/account" element={<AccountPortal />} /><Route path="/" element={<HospitalQueue />} /><Route path="/health-history" element={<HealthHistory />} /><Route path="/staff" element={<StaffWorkflows />} /></Routes></Router>;
}
