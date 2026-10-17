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


def:pub create_booking(patient_name: str, district: str, visit_type: str) -> dict {
    if not patient_name.strip() { return {"ok": False, "message": "Enter the patient's name."}; }
    if not district.strip() { return {"ok": False, "message": "Choose a district."}; }
    bookings = [root -->][?:Appointment];
    token = len(bookings) + 1;
    root ++> Appointment(patient_name=patient_name.strip(), doctor_name="Online GP on duty", district=district, visit_type=visit_type, token_number=token);
    return {"ok": True, "message": f"Booking confirmed. Your token is #{token}.", "token": token};
}
