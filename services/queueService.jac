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
}

node ChatMessage {
    has sender: str = "";
    has text: str = "";
    has district: str = "";
    has created_at: str = "";
    has kind: str = "message";
}


def:pub get_queue() -> list[dict] {
    hospitals = [root -->][?:Hospital];
    if len(hospitals) == 0 {
        root ++> Hospital(name="SuwaSmart Medical Centre", district="Colombo", specialty="General practice", status="On time", current_token=4);
        root ++> Hospital(name="Ratnapura Specialist Clinic", district="Ratnapura", specialty="Cardiology", status="Delayed", delay_minutes=15, current_token=2);
        root ++> Hospital(name="Kandy Diagnostics", district="Kandy", specialty="Diagnostics", status="On time", current_token=1);
        root ++> Appointment(patient_name="Nimali Perera", doctor_name="Dr. Senanayake", district="Colombo", visit_type="Online GP", token_number=4);
        root ++> Appointment(patient_name="Kasun Silva", doctor_name="Dr. Fernando", district="Ratnapura", visit_type="Physical", token_number=5);
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
        if (h["district"] as str).lower() == district.strip().lower() {
            local.append(h);
        } else {
            other.append(h);
        }
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
    for m in messages {
        rows.append({"sender": m.sender, "text": m.text, "district": m.district, "created_at": m.created_at, "kind": m.kind});
    }
    return rows;
}


def:pub triage_symptoms(symptoms: str, district: str) -> dict {
    if not symptoms.strip() {
        return {"ok": False, "message": "Please describe your symptoms first."};
    }
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
        care_match = "Online GP";
        test = "Possible clinician-directed test: Full Blood Count or Dengue NS1.";
    } elif "headache" in lower_symptoms or "dizz" in lower_symptoms {
        guidance = "A clinician should review new, persistent, or worsening symptoms. An online GP can assess you and advise whether a specialist review is needed.";
        care_match = "Online GP";
    } else {
        guidance = "A clinician should assess your symptoms and history before recommending treatment. An online GP is a practical first step.";
    }
    root ++> ChatMessage(sender="You", text=clean_symptoms, district=district, created_at="Now", kind="patient");
    root ++> ChatMessage(sender="SuwaSmart assistant", text=f"Triage guide: {guidance} Suggested care: {care_match}. {test} Location noted: {district}. This is general guidance, not a diagnosis.", district=district, created_at="Now", kind="assistant");
    return {"ok": True, "message": f"Triage guide: {guidance} Suggested care: {care_match}. {test} Location noted: {district}. This is general guidance, not a diagnosis.", "care_match": care_match, "suggested_test": test};
}


def:pub create_booking(patient_name: str, district: str, visit_type: str) -> dict {
    if not patient_name.strip() { return {"ok": False, "message": "Enter the patient's name."}; }
    if not district.strip() { return {"ok": False, "message": "Choose a district."}; }
    bookings = [root -->][?:Appointment];
    token = len(bookings) + 1;
    root ++> Appointment(patient_name=patient_name.strip(), doctor_name="Online GP on duty", district=district, visit_type=visit_type, token_number=token);
    return {"ok": True, "message": f"Booking confirmed. Your token is #{token}.", "token": token};
}
