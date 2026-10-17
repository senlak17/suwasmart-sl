import from "@jac/runtime" { jacLogin, jacSignup, useNavigate }
sv import from ..services.accountService { save_patient_profile, get_my_profile, submit_staff_application }
import from .ui.card { Card, CardHeader, CardTitle, CardDescription, CardContent }
import from .ui.button { Button }
import from .ui.input { Input }


def:pub AccountPortal() -> JsxElement {
    has mode: str = "Sign in";
    has role: str = "doctor";
    has username: str = "";
    has password: str = "";
    has nic: str = "";
    has full_name: str = "";
    has age: str = "";
    has address: str = "";
    has district: str = "Colombo";
    has allergies: str = "";
    has diseases: str = "";
    has diagnosis_history: str = "";
    has medical_reports: str = "";
    has professional_number: str = "";
    has message: str = "";
    has error: str = "";
    nav = useNavigate();

    def change_username(e: ChangeEvent) { username = e.target.value; }
    def change_password(e: ChangeEvent) { password = e.target.value; }
    def change_nic(e: ChangeEvent) { nic = e.target.value; }
    def change_full_name(e: ChangeEvent) { full_name = e.target.value; }
    def change_age(e: ChangeEvent) { age = e.target.value; }
    def change_address(e: ChangeEvent) { address = e.target.value; }
    def change_district(e: ChangeEvent) { district = e.target.value; }
    def change_allergies(e: ChangeEvent) { allergies = e.target.value; }
    def change_diseases(e: ChangeEvent) { diseases = e.target.value; }
    def change_diagnosis(e: ChangeEvent) { diagnosis_history = e.target.value; }
    def change_reports(e: ChangeEvent) { medical_reports = e.target.value; }
    def change_registration(e: ChangeEvent) { professional_number = e.target.value; }
    def change_staff_role(e: ChangeEvent) { role = e.target.value; }

    async def register_patient() {
        error = "";
        message = "";
        if not username.strip() or not password or not nic.strip() or not full_name.strip() { error = "Enter username, password, NIC, and full name."; return; }
        try {
            signup_result: dict | None = None;
            login_ok: bool = False;
            save_result: dict = {};
            signup_result = await jacSignup(username.strip(), password);
            if not (signup_result["success"] as bool) { error = "Registration failed. The username may already be in use."; return; }
            login_ok = await jacLogin(username.strip(), password);
            if not login_ok { error = "Account created. Please sign in to finish your profile."; mode = "Sign in"; return; }
            save_result = await save_patient_profile(username, nic, full_name, int(age or "0"), address, district, allergies, diseases, diagnosis_history, medical_reports);
            if save_result["ok"] as bool { nav("/"); }
            else { error = save_result["message"] as str; }
        } except Exception { error = "Registration could not be completed. Check your details and try again."; }
    }

    async def login_patient() {
        error = "";
        message = "";
        if not username.strip() or not password or not nic.strip() { error = "Enter your username, password, and NIC."; return; }
        try {
            ok: bool = False;
            profile: dict = {};
            ok = await jacLogin(username.strip(), password);
            if not ok { error = "Sign-in failed. Check your credentials."; return; }
            profile = await get_my_profile();
            if not (profile["ok"] as bool) or (profile["nic"] as str) != nic.strip() {
                error = "The NIC does not match this account.";
                return;
            }
            nav("/");
        } except Exception { error = "Sign-in could not be completed. Check your credentials."; }
    }

    async def submit_staff() {
        error = "";
        message = "";
        try {
            result = await submit_staff_application(full_name, username, professional_number, role);
            if result["ok"] as bool { message = result["message"] as str; }
            else { error = result["message"] as str; }
        } except Exception { error = "Staff application could not be submitted."; }
    }

    return <main className="min-h-svh bg-muted/40 text-foreground">
        <div className="mx-auto grid min-h-svh w-full max-w-6xl gap-6 px-4 py-6 md:grid-cols-[1fr_1fr] md:items-center sm:px-6">
            <section className="flex min-h-64 flex-col justify-between gap-8 rounded-2xl bg-primary p-7 text-primary-foreground shadow-sm sm:p-10">
                <div><p className="font-semibold tracking-tight">SuwaSmart SL</p><p className="mt-2 text-sm text-primary-foreground/80">Patient and clinical staff access</p></div>
                <div className="flex flex-col gap-4"><h1 className="text-balance text-3xl font-semibold tracking-tight sm:text-4xl">Care records and clinic access, in one place.</h1><p className="max-w-lg text-sm leading-relaxed text-primary-foreground/80">Patients can keep their health history together. Clinical staff apply with their professional registration number.</p></div>
                <div className="rounded-xl bg-primary-foreground/10 p-4 text-sm"><strong>Emergency?</strong> Call 1990 for Suwa Seriya ambulance assistance.</div>
            </section>
            <Card className="shadow-sm">
                <CardHeader><CardTitle>Account portal</CardTitle><CardDescription>Register or sign in to continue to SuwaSmart SL.</CardDescription></CardHeader>
                <CardContent className="flex flex-col gap-4">
                    <div className="flex flex-wrap gap-2"><Button variant={"default" if mode == "Sign in" else "outline"} onClick={lambda { mode = "Sign in"; }}>Sign in</Button><Button variant={"default" if mode == "Patient registration" else "outline"} onClick={lambda { mode = "Patient registration"; role = "patient"; }}>Patient registration</Button><Button variant={"default" if mode == "Staff application" else "outline"} onClick={lambda { mode = "Staff application"; }}>Staff application</Button></div>
                    {mode == "Staff application" and <>
                        <label className="flex flex-col gap-1.5 text-sm font-medium">Staff role<select className="h-10 rounded-md border border-input bg-background px-3 text-sm" value={role} onChange={change_staff_role}><option>doctor</option><option>lab_staff</option></select></label>
                        <label className="flex flex-col gap-1.5 text-sm font-medium">Full name<Input value={full_name} onChange={change_full_name} placeholder="Name as registered" /></label>
                        <label className="flex flex-col gap-1.5 text-sm font-medium">Username<Input value={username} onChange={change_username} placeholder="Choose a username" /></label>
                        <label className="flex flex-col gap-1.5 text-sm font-medium">Professional registration number<Input value={professional_number} onChange={change_registration} placeholder="Required for staff review" /></label>
                        <Button onClick={submit_staff}>Submit staff application</Button>
                    </>}
                    {mode == "Sign in" and <>
                        <label className="flex flex-col gap-1.5 text-sm font-medium">Username<Input value={username} onChange={change_username} placeholder="Your account username" /></label>
                        <label className="flex flex-col gap-1.5 text-sm font-medium">Password<Input type="password" value={password} onChange={change_password} placeholder="Your password" /></label>
                        <label className="flex flex-col gap-1.5 text-sm font-medium">NIC<Input value={nic} onChange={change_nic} placeholder="NIC used for patient registration" /></label>
                        <Button onClick={login_patient}>Sign in</Button>
                    </>}
                    {mode == "Patient registration" and <>
                        <label className="flex flex-col gap-1.5 text-sm font-medium">Username<Input value={username} onChange={change_username} placeholder="Choose a username" /></label>
                        <label className="flex flex-col gap-1.5 text-sm font-medium">Password<Input type="password" value={password} onChange={change_password} placeholder="Create a password" /></label>
                        <label className="flex flex-col gap-1.5 text-sm font-medium">NIC<Input value={nic} onChange={change_nic} placeholder="National identity card number" /></label>
                        <label className="flex flex-col gap-1.5 text-sm font-medium">Full name<Input value={full_name} onChange={change_full_name} placeholder="Name as shown on your NIC" /></label>
                        <label className="flex flex-col gap-1.5 text-sm font-medium">Age<Input type="number" min="0" max="120" value={age} onChange={change_age} placeholder="Age in years" /></label>
                        <label className="flex flex-col gap-1.5 text-sm font-medium">Address<Input value={address} onChange={change_address} placeholder="Street and town" /></label>
                        <label className="flex flex-col gap-1.5 text-sm font-medium">District<select className="h-10 rounded-md border border-input bg-background px-3 text-sm" value={district} onChange={change_district}><option>Colombo</option><option>Ratnapura</option><option>Kandy</option><option>Galle</option></select></label>
                        <label className="flex flex-col gap-1.5 text-sm font-medium">Allergies<Input value={allergies} onChange={change_allergies} placeholder="List allergies or enter None known" /></label>
                        <label className="flex flex-col gap-1.5 text-sm font-medium">Diseases and conditions<Input value={diseases} onChange={change_diseases} placeholder="Current or previous conditions" /></label>
                        <label className="flex flex-col gap-1.5 text-sm font-medium">Diagnosis history<Input value={diagnosis_history} onChange={change_diagnosis} placeholder="Previous diagnoses and dates" /></label>
                        <label className="flex flex-col gap-1.5 text-sm font-medium">Medical reports summary<Input value={medical_reports} onChange={change_reports} placeholder="Summarize prior report findings" /></label>
                        <Button onClick={register_patient}>Create patient account</Button>
                    </>}
                    {message != "" and <p className="rounded-lg bg-primary/10 p-3 text-sm text-primary">{message}</p>}
                    {error != "" and <p className="text-sm text-destructive">{error}</p>}
                    <p className="text-xs text-muted-foreground">Passwords are managed by Jac authentication. Patient health details are stored in the signed-in account's private graph.</p>
                </CardContent>
            </Card>
        </div>
    </main>;
}
