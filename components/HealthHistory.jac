sv import from ..services.accountService { get_health_history, add_health_history_entry }
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
        <header className="flex flex-wrap items-center justify-between gap-3 rounded-2xl border bg-card p-5 shadow-sm"><div><p className="font-semibold">SuwaSmart <span className="text-primary">SL</span></p><p className="text-xs text-muted-foreground">Patient health record</p></div><Link to="/" className="rounded-md border px-3 py-2 text-sm hover:bg-muted">Patient dashboard</Link></header>
        <div><h1 className="text-2xl font-semibold tracking-tight">Health history tracker</h1><p className="text-sm text-muted-foreground">A dated view of allergies, conditions, diagnoses, and report summaries.</p></div>
        <div className="grid gap-5 lg:grid-cols-[0.8fr_1.2fr]">
            <Card className="shadow-sm"><CardHeader><CardTitle>Add health history</CardTitle><CardDescription>Keep a personal timeline for future consultations.</CardDescription></CardHeader><CardContent className="flex flex-col gap-4">
                <label className="flex flex-col gap-1.5 text-sm font-medium">Category<select className="h-10 rounded-md border border-input bg-background px-3 text-sm" value={category} onChange={lambda (e: ChangeEvent) { category = e.target.value; }}><option>Allergy</option><option>Disease</option><option>Diagnosis</option><option>Medical report</option><option>Medication note</option></select></label>
                <label className="flex flex-col gap-1.5 text-sm font-medium">Title<Input value={title} onChange={change_title} placeholder="e.g. Asthma review" /></label>
                <label className="flex flex-col gap-1.5 text-sm font-medium">Date<Input type="date" value={recorded_at} onChange={change_date} /></label>
                <label className="flex flex-col gap-1.5 text-sm font-medium">Details<Input value={detail} onChange={change_detail} placeholder="Clinician, findings, or report summary" /></label>
                <Button onClick={save_entry}>Save health entry</Button>
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
