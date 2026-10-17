node PatientProfile {
    has username: str = "";
    has nic: str = "";
    has full_name: str = "";
    has role: str = "patient";
    has age: int = 0;
    has address: str = "";
    has district: str = "";
    has allergies: str = "";
    has diseases: str = "";
    has diagnosis_history: str = "";
    has medical_reports: str = "";
}

node HealthHistoryEntry {
    has category: str = "";
    has title: str = "";
    has detail: str = "";
    has recorded_at: str = "";
}

node StaffApplication {
    has full_name: str = "";
    has username: str = "";
    has professional_number: str = "";
    has role: str = "";
    has status: str = "Pending admin approval";
}


def:priv save_patient_profile(username: str, nic: str, full_name: str, age: int, address: str, district: str, allergies: str, diseases: str, diagnosis_history: str, medical_reports: str) -> dict {
    if not username.strip() or not nic.strip() or not full_name.strip() { return {"ok": False, "message": "Name, username, and NIC are required."}; }
    if age < 0 or age > 120 { return {"ok": False, "message": "Enter a valid age."}; }
    for profile in [root -->][?:PatientProfile] {
        if profile.role == "patient" {
            profile.username = username.strip();
            profile.nic = nic.strip();
            profile.full_name = full_name.strip();
            profile.age = age;
            profile.address = address.strip();
            profile.district = district.strip();
            profile.allergies = allergies.strip();
            profile.diseases = diseases.strip();
            profile.diagnosis_history = diagnosis_history.strip();
            profile.medical_reports = medical_reports.strip();
            return {"ok": True, "message": "Patient profile saved."};
        }
    }
    root ++> PatientProfile(username=username.strip(), nic=nic.strip(), full_name=full_name.strip(), age=age, address=address.strip(), district=district.strip(), allergies=allergies.strip(), diseases=diseases.strip(), diagnosis_history=diagnosis_history.strip(), medical_reports=medical_reports.strip());
    return {"ok": True, "message": "Patient profile saved."};
}


def:priv get_my_profile() -> dict {
    profiles = [root -->][?:PatientProfile];
    if len(profiles) == 0 { return {"ok": False, "message": "No patient profile is linked to this account."}; }
    p = profiles[0];
    return {"ok": True, "username": p.username, "nic": p.nic, "full_name": p.full_name, "role": p.role, "age": p.age, "address": p.address, "district": p.district, "allergies": p.allergies, "diseases": p.diseases, "diagnosis_history": p.diagnosis_history, "medical_reports": p.medical_reports};
}


def:priv add_health_history_entry(category: str, title: str, detail: str, recorded_at: str) -> dict {
    profiles = [root -->][?:PatientProfile];
    if len(profiles) == 0 or profiles[0].role != "patient" { return {"ok": False, "message": "A patient profile is required to add health history."}; }
    if not category.strip() or not title.strip() { return {"ok": False, "message": "Choose a category and enter a title."}; }
    root ++> HealthHistoryEntry(category=category.strip(), title=title.strip(), detail=detail.strip(), recorded_at=recorded_at.strip());
    return {"ok": True, "message": "Health history entry saved."};
}


def:priv get_health_history() -> list[dict] {
    profiles = [root -->][?:PatientProfile];
    if len(profiles) == 0 or profiles[0].role != "patient" { return []; }
    entries: list[dict] = [];
    p = profiles[0];
    if p.allergies.strip() { entries.append({"category": "Allergy", "title": "Allergies", "detail": p.allergies, "recorded_at": "Registration profile"}); }
    if p.diseases.strip() { entries.append({"category": "Disease", "title": "Medical conditions", "detail": p.diseases, "recorded_at": "Registration profile"}); }
    if p.diagnosis_history.strip() { entries.append({"category": "Diagnosis", "title": "Diagnosis history", "detail": p.diagnosis_history, "recorded_at": "Registration profile"}); }
    if p.medical_reports.strip() { entries.append({"category": "Report", "title": "Medical reports summary", "detail": p.medical_reports, "recorded_at": "Registration profile"}); }
    for item in [root -->][?:HealthHistoryEntry] {
        entries.append({"category": item.category, "title": item.title, "detail": item.detail, "recorded_at": item.recorded_at});
    }
    return entries;
}


def:pub submit_staff_application(full_name: str, username: str, professional_number: str, role: str) -> dict {
    if not full_name.strip() or not username.strip() or not professional_number.strip() { return {"ok": False, "message": "Name, username, and professional registration number are required."}; }
    staff_role = role.strip().lower().replace(" ", "_");
    if staff_role != "doctor" and staff_role != "lab_staff" { return {"ok": False, "message": f"Select Doctor or Lab Staff (received: {role})."}; }
    for existing in [root.shared -->][?:StaffApplication] {
        if existing.professional_number == professional_number.strip() { return {"ok": False, "message": "That registration number already has an application."}; }
    }
    root.shared ++> StaffApplication(full_name=full_name.strip(), username=username.strip(), professional_number=professional_number.strip(), role=staff_role);
    return {"ok": True, "message": "Application submitted. Admin approval is required before staff access is granted."};
}
