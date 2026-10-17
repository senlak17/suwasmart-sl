import from ..services.queueService { get_staff_appointments, update_doctor_queue, get_lab_tests, update_lab_test }
import from .ui.card { Card, CardHeader, CardTitle, CardDescription, CardContent }
import from .ui.button { Button }
import from .ui.input { Input }
import from .ui.badge { Badge }
import from "@jac/runtime" { Link, jacIsLoggedIn, Navigate }
import "../styles/global.css";


def:pub StaffWorkflows() -> JsxElement {
    has role: str = "Doctor";
    has appointments: list[dict] = [];
    has lab_tests: list[dict] = [];
    has delay: str = "15";
    has token: str = "2";
    has doctor_status: str = "Delayed";
    has report_test_name: str = "Full Blood Count";
    has report_status: str = "Scheduled";
    has metric: str = "";
    has measured: str = "";
    has normal_range: str = "";
    has flag: str = "Normal";
    has comment: str = "";
    has notice: str = "";
    has error: str = "";
    has loading: bool = True;

    async can with entry {
        try {
            appointments = await get_staff_appointments();
            lab_tests = await get_lab_tests();
            loading = False;
        } except Exception {
            error = "Staff workflow data could not be loaded.";
            loading = False;
        }
    }

    def set_role(new_role: str) { role = new_role; notice = ""; error = ""; }
    def update_delay(e: ChangeEvent) { delay = e.target.value; }
    def update_token(e: ChangeEvent) { token = e.target.value; }
    def update_metric(e: ChangeEvent) { metric = e.target.value; }
    def update_measured(e: ChangeEvent) { measured = e.target.value; }
    def update_range(e: ChangeEvent) { normal_range = e.target.value; }
    def update_flag(e: ChangeEvent) { flag = e.target.value; }
    def update_comment(e: ChangeEvent) { comment = e.target.value; }

    async def save_queue() {
        error = "";
        if not delay.strip() or not token.strip() { error = "Enter a valid delay and current token number."; return; }
        try {
            delay_value = int(delay);
            token_value = int(token);
            result = await update_doctor_queue(delay_value, token_value, doctor_status);
            if result["ok"] as bool {
                notice = result["message"] as str;
                appointments = await get_staff_appointments();
            } else { error = result["message"] as str; }
        } except Exception { error = "Enter a valid delay and current token number."; }
    }

    async def save_report(test_name: str, status: str, metric: str, measured: str, normal_range: str, flag: str, comment: str) {
        error = "";
        if status == "Report Ready" and (not metric.strip() or not measured.strip() or not normal_range.strip() or not comment.strip()) {
            error = "Complete all report fields before marking the report ready.";
            return;
        }
        try {
            result = await update_lab_test(test_name, status, metric, measured, normal_range, flag, comment);
            if result["ok"] as bool {
                notice = result["message"] as str;
                lab_tests = await get_lab_tests();
            } else { error = result["message"] as str; }
        } except Exception { error = "Lab update could not be saved. Please try again."; }
    }

    if not jacIsLoggedIn() { return <Navigate to="/account" replace={True} />; }
    return <main className="min-h-screen bg-muted/40 text-foreground">
        <div className="mx-auto flex w-full max-w-7xl flex-col gap-6 px-4 py-6 sm:px-6 lg:px-8">
            <header className="flex flex-wrap items-center justify-between gap-4 rounded-2xl border bg-card px-5 py-4 shadow-sm">
                <div><p className="font-semibold tracking-tight">SUVAVI <span className="text-primary">SL</span></p><p className="text-xs text-muted-foreground">Clinical operations workspace</p></div>
                <div className="flex flex-wrap gap-2"><Link to="/" className="rounded-md border px-3 py-2 text-sm font-medium hover:bg-muted">Patient dashboard</Link><Button size="sm" variant={"default" if role == "Doctor" else "outline"} onClick={lambda { set_role("Doctor"); }}>Doctor</Button><Button size="sm" variant={"default" if role == "Lab Staff" else "outline"} onClick={lambda { set_role("Lab Staff"); }}>Lab Staff</Button></div>
            </header>
            <div className="flex flex-wrap items-end justify-between gap-3"><div><h1 className="text-2xl font-semibold tracking-tight">{role} workspace</h1><p className="text-sm text-muted-foreground">Manage today's clinic queue and diagnostic workflow.</p></div><Badge variant="secondary">Demo staff account</Badge></div>
            {notice != "" and <p className="rounded-lg border border-primary/20 bg-primary/10 px-4 py-3 text-sm font-medium text-primary">{notice}</p>}
            {error != "" and <p className="rounded-lg border border-destructive/30 bg-destructive/5 px-4 py-3 text-sm text-destructive">{error}</p>}
            {loading and <Card><CardContent className="py-10 text-sm text-muted-foreground">Loading today's worklist…</CardContent></Card>}
            {not loading and role == "Doctor" and <section className="grid gap-5 lg:grid-cols-[0.75fr_1.25fr]">
                <Card className="shadow-sm"><CardHeader><CardTitle>Live timetable</CardTitle><CardDescription>Ratnapura specialist clinic · Physical queue</CardDescription></CardHeader><CardContent className="flex flex-col gap-4">
                    <label className="flex flex-col gap-1.5 text-sm font-medium">Queue status<select className="h-10 rounded-md border border-input bg-background px-3 text-sm" value={doctor_status} onChange={lambda (e: ChangeEvent) { doctor_status = e.target.value; }}><option>On Time</option><option>Delayed</option><option>Cancelled</option></select></label>
                    <label className="flex flex-col gap-1.5 text-sm font-medium">Delay in minutes<Input type="number" min="0" max="180" value={delay} onChange={update_delay} /></label>
                    <label className="flex flex-col gap-1.5 text-sm font-medium">Current token number<Input type="number" min="1" value={token} onChange={update_token} /></label>
                    <Button onClick={save_queue}>Update live queue</Button><p className="text-xs text-muted-foreground">Physical patient estimates update after saving. Cancelled sessions are marked for rescheduling.</p>
                </CardContent></Card>
                <Card className="shadow-sm"><CardHeader><CardTitle>Today's channel bookings</CardTitle><CardDescription>Patient token, clinical brief, and updated arrival estimate.</CardDescription></CardHeader><CardContent className="flex flex-col gap-3">
                    {len(appointments) == 0 and <p className="rounded-lg border border-dashed p-8 text-center text-sm text-muted-foreground">No physical channel bookings today.</p>}
                    {for (i, appt) in enumerate(appointments) {<div key={str(i)} className="rounded-xl border bg-background p-4"><div className="flex flex-wrap items-start justify-between gap-3"><div><p className="font-semibold">{appt["patient_name"] as str} · Token #{appt["token"] as int}</p><p className="text-sm text-muted-foreground">{appt["district"] as str} · {appt["visit_type"] as str}</p></div><Badge variant={"destructive" if (appt["status"] as str) == "Reschedule required" else "secondary"}>{appt["status"] as str}</Badge></div><div className="mt-3 grid gap-2 text-sm sm:grid-cols-2"><p><span className="text-muted-foreground">Symptoms: </span>{appt["symptoms"] as str}</p><p><span className="text-muted-foreground">Allergies: </span>{appt["allergies"] as str}</p><p><span className="text-muted-foreground">History: </span>{appt["history"] as str}</p><p><span className="text-muted-foreground">Arrive: </span><strong>{appt["predicted_arrival"] as str}</strong></p></div></div>}}
                </CardContent></Card>
            </section>}
            {not loading and role == "Lab Staff" and <section className="flex flex-col gap-4">
                <div><h2 className="text-xl font-semibold tracking-tight">Scans and lab tests</h2><p className="text-sm text-muted-foreground">Move each booking through collection, analysis, and report release.</p></div>
                {len(lab_tests) == 0 and <Card><CardContent className="py-10 text-center text-sm text-muted-foreground">No tests are scheduled.</CardContent></Card>}
                {for (i, test_row) in enumerate(lab_tests) {<StaffLabCard key={str(i)} test_row={test_row} onSave={save_report} />}}
            </section>}
            <footer className="border-t pt-4 text-xs text-muted-foreground">Updates are simulated for demonstration and saved to the SUVAVI graph.</footer>
        </div>
    </main>;
}


def:pub StaffLabCard(test_row: dict, onSave: Callable[[str, str, str, str, str, str, str], None]) -> JsxElement {
    has status: str = test_row["status"] as str;
    has metric: str = test_row["key_metric_name"] as str;
    has measured: str = test_row["measured_value"] as str;
    has normal_range: str = test_row["normal_range"] as str;
    has health_flag: str = test_row["health_flag"] as str;
    has comment: str = test_row["clinical_comment"] as str;
    if health_flag == "" { health_flag = "Normal"; }
    def update_status(e: ChangeEvent) { status = e.target.value; }
    def update_metric(e: ChangeEvent) { metric = e.target.value; }
    def update_measured(e: ChangeEvent) { measured = e.target.value; }
    def update_range(e: ChangeEvent) { normal_range = e.target.value; }
    def update_flag(e: ChangeEvent) { health_flag = e.target.value; }
    def update_comment(e: ChangeEvent) { comment = e.target.value; }
    def submit(e: MouseEvent) { onSave(test_row["test_name"] as str, status, metric, measured, normal_range, health_flag, comment); }
    return <Card className="shadow-sm"><CardHeader className="flex flex-row items-start justify-between gap-4"><div><CardTitle className="text-base">{test_row["test_name"] as str}</CardTitle><CardDescription>{test_row["patient_name"] as str} · {test_row["district"] as str} · {test_row["scheduled_at"] as str}</CardDescription><p className="mt-1 text-xs text-muted-foreground">{test_row["center"] as str}</p></div><Badge variant={"secondary" if status == "Report Ready" else "outline"}>{status}</Badge></CardHeader><CardContent className="flex flex-col gap-4 border-t pt-4">
        <label className="flex flex-col gap-1.5 text-sm font-medium">Workflow status<select className="h-10 rounded-md border border-input bg-background px-3 text-sm" value={status} onChange={update_status}><option>Scheduled</option><option>Sample Collected / Scanned</option><option>Report Ready</option></select></label>
        <div className="grid gap-3 sm:grid-cols-2"><label className="flex flex-col gap-1.5 text-sm font-medium">Key metric<Input value={metric} onChange={update_metric} placeholder="e.g. Platelet count" /></label><label className="flex flex-col gap-1.5 text-sm font-medium">Measured value<Input value={measured} onChange={update_measured} placeholder="e.g. 180 x10^9/L" /></label><label className="flex flex-col gap-1.5 text-sm font-medium">Normal range<Input value={normal_range} onChange={update_range} placeholder="e.g. 150–400 x10^9/L" /></label><label className="flex flex-col gap-1.5 text-sm font-medium">Health flag<select className="h-10 rounded-md border border-input bg-background px-3 text-sm" value={health_flag} onChange={update_flag}><option>Normal</option><option>Borderline</option><option>Attention Required</option></select></label></div>
        <label className="flex flex-col gap-1.5 text-sm font-medium">Clinical comment<Input value={comment} onChange={update_comment} placeholder="Short clinical note for the report" /></label>
        <Button variant="outline" onClick={submit}>Save lab update</Button>
        {status == "Report Ready" and <div className="rounded-lg bg-muted p-3 text-sm"><p className="font-medium">{metric}: {measured} · {health_flag}</p><p className="text-muted-foreground">Range {normal_range}. {comment}</p></div>}
    </CardContent></Card>;
}
