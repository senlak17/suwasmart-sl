node Hospital {
    has name: str = "";
    has district: str = "";
    has specialty: str = "";
    has status: str = "On time";
    has delay_minutes: int = 0;
    has current_token: int = 1;
}

node Appointment {
    has patient_name: str = "";
    has doctor_name: str = "";
    has district: str = "";
    has visit_type: str = "Online";
    has token_number: int = 0;
    has status: str = "Booked";
    has scheduled_start: str = "09:00";
    has predicted_arrival: str = "09:00";
    has allergies: str = "Not recorded";
    has history: str = "Not recorded";
    has symptoms: str = "Routine consultation";
}

node ChatMessage {
    has sender: str = "";
    has text: str = "";
    has district: str = "";
    has created_at: str = "";
    has kind: str = "message";
}

node LabTest {
    has patient_name: str = "";
    has district: str = "";
    has test_name: str = "";
    has center: str = "";
    has scheduled_at: str = "";
    has status: str = "Scheduled";
    has key_metric_name: str = "";
    has measured_value: str = "";
    has normal_range: str = "";
    has health_flag: str = "";
    has clinical_comment: str = "";
}


def:pub get_queue() -> list[dict] {
    hospitals = [root -->][?:Hospital];
    if len(hospitals) == 0 {
        root ++> Hospital(name="SuwaSmart Medical Centre", district="Colombo", specialty="General practice", status="On time", current_token=4);
        root ++> Hospital(name="Ratnapura Specialist Clinic", district="Ratnapura", specialty="Cardiology", status="Delayed", delay_minutes=15, current_token=2);
        root ++> Hospital(name="Kandy Diagnostics", district="Kandy", specialty="Diagnostics", status="On time", current_token=1);
        root ++> Appointment(patient_name="Nimali Perera", doctor_name="Dr. Senanayake", district="Colombo", visit_type="Physical specialist", token_number=4, status="Booked", allergies="Penicillin", history="Hypertension", symptoms="Follow-up review");
        root ++> Appointment(patient_name="Kasun Silva", doctor_name="Dr. Fernando", district="Ratnapura", visit_type="Physical", token_number=5, status="Booked", scheduled_start="10:00", predicted_arrival="10:30", allergies="None known", history="Asthma", symptoms="Back discomfort");
        root ++> Appointment(patient_name="Amaya Perera", doctor_name="Dr. Fernando", district="Ratnapura", visit_type="Physical", token_number=6, status="Booked", scheduled_start="10:00", predicted_arrival="10:40", symptoms="Joint pain");
        root ++> LabTest(patient_name="Nimali Perera", district="Colombo", test_name="Full Blood Count", center="SuwaSmart Medical Centre Lab", scheduled_at="Today · 10:30", status="Sample Collected / Scanned");
        root ++> LabTest(patient_name="Kasun Silva", district="Ratnapura", test_name="Dengue NS1", center="Ratnapura Specialist Clinic", scheduled_at="Today · 11:00", status="Scheduled");
        hospitals = [root -->][?:Hospital];
    }
    rows: list[dict] = [];
    for h in hospitals {
        rows.append({"name": h.name, "district": h.district, "specialty": h.specialty, "status": h.status, "delay": h.delay_minutes, "token": h.current_token});
    }
    return rows;
}


def:pub get_suggested_hospitals(district: str) -> list[dict] {
    all_hospitals = get_queue();
    local: list[dict] = [];
    other: list[dict] = [];
    for h in all_hospitals {
        if (h["district"] as str).lower() == district.strip().lower() { local.append(h); }
        else { other.append(h); }
    }
    if len(local) > 0 { return local + other; }
    return other;
}


def:pub get_chat_messages() -> list[dict] {
    messages = [root -->][?:ChatMessage];
    if len(messages) == 0 {
        root ++> ChatMessage(sender="SuwaSmart assistant", text="Hello. Tell me what symptoms you are experiencing. I can offer general next-step guidance, but I cannot diagnose. For an emergency, call 1990 now.", district="Colombo", created_at="Today", kind="assistant");
        messages = [root -->][?:ChatMessage];
    }
    rows: list[dict] = [];
    for m in messages { rows.append({"sender": m.sender, "text": m.text, "district": m.district, "created_at": m.created_at, "kind": m.kind}); }
    return rows;
}


def _llm_symptom_guidance(symptoms: str, district: str) -> str by llm(temperature=0.2, max_tokens=180);
sem _llm_symptom_guidance = "Give brief, cautious, non-diagnostic next-step guidance for the user's symptoms. Do not prescribe medication, assert a diagnosis, or contradict emergency advice. Encourage a licensed clinician to assess the patient.";
sem _llm_symptom_guidance.symptoms = "The patient's own description of symptoms.";
sem _llm_symptom_guidance.district = "The patient's Sri Lankan district, for general care context only.";


def:pub triage_symptoms(symptoms: str, district: str) -> dict {
    if not symptoms.strip() { return {"ok": False, "message": "Please describe your symptoms first."}; }
    clean_symptoms = symptoms.strip();
    lower_symptoms = clean_symptoms.lower();
    guidance = "A prompt online GP consultation is a reasonable next step. Share when the symptoms began and any medicines or allergies with the clinician.";
    care_match = "Online GP";
    test = "A clinician can decide whether any tests are needed after reviewing your symptoms.";
    if "chest pain" in lower_symptoms or "shortness of breath" in lower_symptoms or "difficulty breathing" in lower_symptoms {
        guidance = "These symptoms can be urgent. Call 1990 or go to the nearest emergency department now. Do not wait for a chat response.";
        care_match = "Emergency care now";
    } elif "joint" in lower_symptoms or "back pain" in lower_symptoms {
        guidance = "A physical assessment may help. Start with an online GP, who can refer you to an orthopaedic specialist if needed.";
        care_match = "Online GP, then orthopaedics if advised";
    } elif "fever" in lower_symptoms or "dengue" in lower_symptoms {
        guidance = "Please contact a clinician promptly, especially for persistent or high fever. A clinician may consider a Full Blood Count or Dengue NS1 based on your history.";
        test = "Possible clinician-directed test: Full Blood Count or Dengue NS1.";
    } elif "headache" in lower_symptoms or "dizz" in lower_symptoms {
        guidance = "A clinician should review new, persistent, or worsening symptoms. An online GP can assess you and advise whether a specialist review is needed.";
    } else {
        guidance = "A clinician should assess your symptoms and history before recommending treatment. An online GP is a practical first step.";
    }
    ai_guidance = "";
    if care_match != "Emergency care now" {
        try { ai_guidance = _llm_symptom_guidance(clean_symptoms, district).strip(); }
        except Exception { ai_guidance = ""; }
    }
    if ai_guidance != "" and care_match != "Online GP, then orthopaedics if advised" and test == "A clinician can decide whether any tests are needed after reviewing your symptoms." { guidance = ai_guidance; }
    reply = f"Triage guide: {guidance} Suggested care: {care_match}. {test} Location noted: {district}. This is general guidance, not a diagnosis.";
    root ++> ChatMessage(sender="You", text=clean_symptoms, district=district, created_at="Now", kind="patient");
    root ++> ChatMessage(sender="SuwaSmart assistant", text=reply, district=district, created_at="Now", kind="assistant");
    return {"ok": True, "message": guidance, "care_match": care_match, "suggested_test": test};
}


def:pub get_staff_appointments() -> list[dict] {
    appts = [root -->][?:Appointment];
    if len(appts) == 0 { get_queue(); appts = [root -->][?:Appointment]; }
    rows: list[dict] = [];
    for a in appts {
        if "physical" in a.visit_type.lower() and a.doctor_name == "Dr. Fernando" {
            rows.append({"patient_name": a.patient_name, "doctor_name": a.doctor_name, "district": a.district, "visit_type": a.visit_type, "token": a.token_number, "status": a.status, "scheduled_start": a.scheduled_start, "predicted_arrival": a.predicted_arrival, "allergies": a.allergies, "history": a.history, "symptoms": a.symptoms});
        }
    }
    return rows;
}


def:pub update_doctor_queue(delay_minutes: int, current_token: int, status: str) -> dict {
    if delay_minutes < 0 or delay_minutes > 180 { return {"ok": False, "message": "Delay must be between 0 and 180 minutes."}; }
    if current_token < 1 { return {"ok": False, "message": "Current token must be at least 1."}; }
    if status != "On Time" and status != "Delayed" and status != "Cancelled" { return {"ok": False, "message": "Choose On Time, Delayed, or Cancelled."}; }
    hospitals = [root -->][?:Hospital];
    for h in hospitals { if h.district == "Ratnapura" { h.delay_minutes = delay_minutes; h.current_token = current_token; h.status = status; } }
    for a in [root -->][?:Appointment] {
        if "physical" in a.visit_type.lower() and a.district == "Ratnapura" {
            if status == "Cancelled" { a.status = "Reschedule required"; a.predicted_arrival = "Reschedule required"; }
            else {
                a.status = status;
                if a.token_number <= current_token { a.predicted_arrival = a.scheduled_start; }
                elif delay_minutes >= 60 { a.predicted_arrival = "12:00 or later"; }
                elif delay_minutes >= 45 { a.predicted_arrival = "11:45 or later"; }
                elif delay_minutes >= 30 { a.predicted_arrival = "11:30 or later"; }
                elif delay_minutes >= 15 { a.predicted_arrival = "11:15 or later"; }
                else { a.predicted_arrival = "10:00 or later"; }
            }
        }
    }
    return {"ok": True, "message": f"Queue updated: {status}, delay {delay_minutes} minutes, current token #{current_token}. Physical bookings were updated."};
}


def:pub get_lab_tests() -> list[dict] {
    tests = [root -->][?:LabTest];
    if len(tests) == 0 { get_queue(); tests = [root -->][?:LabTest]; }
    rows: list[dict] = [];
    for t in tests { rows.append({"patient_name": t.patient_name, "district": t.district, "test_name": t.test_name, "center": t.center, "scheduled_at": t.scheduled_at, "status": t.status, "key_metric_name": t.key_metric_name, "measured_value": t.measured_value, "normal_range": t.normal_range, "health_flag": t.health_flag, "clinical_comment": t.clinical_comment}); }
    return rows;
}


def:pub update_lab_test(test_name: str, status: str, key_metric_name: str, measured_value: str, normal_range: str, health_flag: str, clinical_comment: str) -> dict {
    if status != "Scheduled" and status != "Sample Collected / Scanned" and status != "Report Ready" { return {"ok": False, "message": "Choose a valid lab workflow status."}; }
    if status == "Report Ready" and (not key_metric_name.strip() or not measured_value.strip() or not normal_range.strip() or not clinical_comment.strip()) { return {"ok": False, "message": "Enter the metric, value, normal range, and clinical comment before releasing a report."}; }
    if health_flag != "" and health_flag != "Normal" and health_flag != "Borderline" and health_flag != "Attention Required" { return {"ok": False, "message": "Choose a valid health flag."}; }
    tests = [root -->][?:LabTest];
    for t in tests {
        if t.test_name == test_name {
            t.status = status;
            if status == "Report Ready" {
                t.key_metric_name = key_metric_name.strip(); t.measured_value = measured_value.strip(); t.normal_range = normal_range.strip(); t.health_flag = health_flag; t.clinical_comment = clinical_comment.strip();
                root ++> ChatMessage(sender="SuwaSmart Lab", text=f"Your {t.test_name} report is ready. Result: {t.key_metric_name} {t.measured_value}; normal range {t.normal_range}. Status: {t.health_flag}. Please review this with your clinician.", district=t.district, created_at="Now", kind="notification");
            }
            return {"ok": True, "message": f"{t.test_name} updated to {status}."};
        }
    }
    return {"ok": False, "message": "Lab booking not found."};
}


def:pub create_booking(patient_name: str, district: str, visit_type: str) -> dict {
    if not patient_name.strip() { return {"ok": False, "message": "Enter the patient's name."}; }
    if not district.strip() { return {"ok": False, "message": "Choose a district."}; }
    bookings = [root -->][?:Appointment];
    token = len(bookings) + 1;
    root ++> Appointment(patient_name=patient_name.strip(), doctor_name="Online GP on duty", district=district, visit_type=visit_type, token_number=token);
    return {"ok": True, "message": f"Booking confirmed. Your token is #{token}.", "token": token};
}
