sv import from ..services.accountService { get_health_history, add_health_history_entry, upload_patient_report }
import from .ui.card { Card, CardHeader, CardTitle, CardDescription, CardContent }
import from .ui.button { Button }
import from .ui.input { Input }
import from .ui.badge { Badge }
import from "@jac/runtime" { Link, jacIsLoggedIn, Navigate }


def:pub HealthHistory() -> JsxElement {
    has entries: list[dict] = [];
    has category: str = "Diagnosis";
    has title: str = "";
    has detail: str = "";
    has recorded_at: str = "";
    has loading: bool = True;
    has error: str = "";
    has message: str = "";
    has upload_message: str = "";
    has upload_error: str = "";

    async can with entry {
        if jacIsLoggedIn() {
            try { entries = await get_health_history(); }
            except Exception { error = "Health history could not be loaded."; }
            loading = False;
        }
    }

    def change_title(e: ChangeEvent) { title = e.target.value; }
    def change_detail(e: ChangeEvent) { detail = e.target.value; }
    def change_date(e: ChangeEvent) { recorded_at = e.target.value; }
    async def save_pdf(e: ChangeEvent) {
        upload_error = "";
        upload_message = "";
        selected = e.target.files[0];
        if not selected { return; }
        if not selected.name.lower().endswith(".pdf") or selected.type != "application/pdf" {
            upload_error = "Choose a PDF file only.";
            return;
        }
        try {
            form_data = new(FormData) as any;
            form_data.append("file", selected);
            token = localStorage.getItem("jac_token") or "";
            response = await fetch("/walker/upload_patient_report", {"method": "POST", "headers": {"Authorization": "Bearer " + token}, "body": form_data});
            response_body = await response.json();
            upload_result = response_body["data"]["reports"][0] as dict;
            if upload_result["ok"] as bool {
                upload_message = upload_result["message"] as str;
                entries = await get_health_history();
            } else { upload_error = upload_result["message"] as str; }
        } except Exception { upload_error = "PDF upload failed. Ensure you are signed in and retry."; }
    }
    async def save_entry() {
        error = "";
        message = "";
        try {
            result = await add_health_history_entry(category, title, detail, recorded_at);
            if result["ok"] as bool {
                message = result["message"] as str;
                title = "";
                detail = "";
                entries = await get_health_history();
            } else { error = result["message"] as str; }
        } except Exception { error = "Entry could not be saved. Sign in as a patient and try again."; }
    }

    if not jacIsLoggedIn() { return <Navigate to="/account" replace={True} />; }
    return <main className="min-h-svh bg-muted/40 text-foreground"><div className="mx-auto flex w-full max-w-6xl flex-col gap-6 px-4 py-6 sm:px-6">
        <header className="flex flex-wrap items-center justify-between gap-3 rounded-2xl border bg-card p-5 shadow-sm"><div><p className="font-semibold">SUVAVI <span className="text-primary">SL</span></p><p className="text-xs text-muted-foreground">Patient health record</p></div><Link to="/" className="rounded-md border px-3 py-2 text-sm hover:bg-muted">Patient dashboard</Link></header>
        <div><h1 className="text-2xl font-semibold tracking-tight">Health history tracker</h1><p className="text-sm text-muted-foreground">A dated view of allergies, conditions, diagnoses, and report summaries.</p></div>
        <div className="grid gap-5 lg:grid-cols-[0.8fr_1.2fr]">
            <Card className="shadow-sm"><CardHeader><CardTitle>Add health history</CardTitle><CardDescription>Keep a personal timeline for future consultations.</CardDescription></CardHeader><CardContent className="flex flex-col gap-4">
                <label className="flex flex-col gap-1.5 text-sm font-medium">Category<select className="h-10 rounded-md border border-input bg-background px-3 text-sm" value={category} onChange={lambda (e: ChangeEvent) { category = e.target.value; }}><option>Allergy</option><option>Disease</option><option>Diagnosis</option><option>Medical report</option><option>Medication note</option></select></label>
                <label className="flex flex-col gap-1.5 text-sm font-medium">Title<Input value={title} onChange={change_title} placeholder="e.g. Asthma review" /></label>
                <label className="flex flex-col gap-1.5 text-sm font-medium">Date<Input type="date" value={recorded_at} onChange={change_date} /></label>
                <label className="flex flex-col gap-1.5 text-sm font-medium">Details<Input value={detail} onChange={change_detail} placeholder="Clinician, findings, or report summary" /></label>
                <Button onClick={save_entry}>Save health entry</Button>
                <div className="flex flex-col gap-2 rounded-xl border border-dashed p-4"><p className="font-medium">Attach a medical report</p><p className="text-xs text-muted-foreground">PDF only. Uploaded files are stored under your patient account.</p><input type="file" accept="application/pdf,.pdf" onChange={save_pdf} className="block w-full text-sm file:mr-3 file:rounded-md file:border-0 file:bg-primary file:px-3 file:py-2 file:text-primary-foreground" />{upload_message != "" and <p className="text-sm text-primary">{upload_message}</p>}{upload_error != "" and <p className="text-sm text-destructive">{upload_error}</p>}</div>
                {message != "" and <p className="text-sm text-primary">{message}</p>}
                {error != "" and <p className="text-sm text-destructive">{error}</p>}
            </CardContent></Card>
            <Card className="shadow-sm"><CardHeader><CardTitle>Your timeline</CardTitle><CardDescription>Registration details and entries saved to your private account graph.</CardDescription></CardHeader><CardContent className="flex flex-col gap-3">
                {loading and <p className="py-8 text-sm text-muted-foreground">Loading health history…</p>}
                {not loading and len(entries) == 0 and <div className="rounded-xl border border-dashed p-8 text-center"><p className="font-semibold">No history entries yet</p><p className="mt-1 text-sm text-muted-foreground">Add an allergy, condition, diagnosis, or report summary to begin.</p></div>}
                {for (i, item) in enumerate(entries) {<article key={str(i)} className="rounded-xl border bg-background p-4"><div className="flex flex-wrap items-start justify-between gap-3"><div><p className="font-semibold">{item["title"] as str}</p><p className="text-xs text-muted-foreground">{item["recorded_at"] as str}</p></div><Badge variant="secondary">{item["category"] as str}</Badge></div><p className="mt-3 text-sm leading-relaxed">{item["detail"] as str}</p></article>}}
            </CardContent></Card>
        </div>
    </div></main>;
}
