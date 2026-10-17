sv import from ..services.queueService { get_queue, create_booking }
import from .ui.card { Card, CardHeader, CardTitle, CardDescription, CardContent }
import from .ui.button { Button }
import from .ui.input { Input }
import from .ui.badge { Badge }


def:pub HospitalQueue() -> JsxElement {
    has role: str = "Patient";
    has rows: list[dict] = [];
    has patient_name: str = "";
    has district: str = "Colombo";
    has visit_type: str = "Online GP";
    has loading: bool = True;
    has error: str = "";
    has notice: str = "";

    async can with entry {
        try {
            rows = await get_queue();
            loading = False;
        } except Exception {
            error = "Queue data could not be loaded. Refresh to try again.";
            loading = False;
        }
    }

    def update_patient(e: ChangeEvent) { patient_name = e.target.value; }
    def update_district(e: ChangeEvent) { district = e.target.value; }
    def update_type(e: ChangeEvent) { visit_type = e.target.value; }
    async def book_visit() {
        notice = "";
        error = "";
        if not patient_name.strip() { error = "Enter the patient's name before booking."; return; }
        try {
            result = await create_booking(patient_name, district, visit_type);
            if result["ok"] as bool {
                notice = result["message"] as str;
                patient_name = "";
                rows = await get_queue();
            } else { error = result["message"] as str; }
        } except Exception {
            error = "Booking could not be saved. Please try again.";
        }
    }

    return <main className="min-h-screen bg-muted/40 text-foreground">
        <div className="mx-auto flex w-full max-w-7xl flex-col gap-6 px-4 py-6 sm:px-6 lg:px-8">
            <header className="flex flex-wrap items-center justify-between gap-4 rounded-2xl border bg-card px-5 py-4 shadow-sm">
                <div className="flex items-center gap-3"><div className="flex size-10 items-center justify-center rounded-xl bg-primary text-primary-foreground font-bold">S</div><div><p className="font-semibold tracking-tight">SuwaSmart <span className="text-primary">SL</span></p><p className="text-xs text-muted-foreground">Care without the waiting room</p></div></div>
                <div className="flex flex-wrap items-center gap-2"><span className="mr-1 text-xs font-medium text-muted-foreground">DEMO VIEW</span>
                    {for r in ["Patient", "Doctor", "Lab Staff", "Admin"] {<Button key={r} size="sm" variant={"default" if role == r else "outline"} onClick={lambda { role = r; }}>{r}</Button>}}
                    <Button variant="destructive" size="sm" onClick={lambda { notice = "1990 Suwa Seriya dispatch logged for Colombo. Help is on the way."; }}>Pre-Login 1990 SOS</Button>
                </div>
            </header>
            <section className="grid gap-5 lg:grid-cols-[1.5fr_1fr]">
                <div className="flex flex-col justify-center gap-4 rounded-2xl bg-primary px-6 py-8 text-primary-foreground shadow-sm sm:px-9">
                    <Badge variant="secondary" className="w-fit">Sri Lanka care access</Badge>
                    <h1 className="max-w-2xl text-balance text-3xl font-semibold tracking-tight sm:text-4xl">Spend less time waiting. More time getting care.</h1>
                    <p className="max-w-xl text-sm leading-relaxed text-primary-foreground/80">Book a doctor, see live queue estimates, and plan your arrival from one simple care desk.</p>
                    <div className="flex flex-wrap gap-3"><span className="rounded-lg bg-primary-foreground/15 px-3 py-2 text-sm">District-aware care</span><span className="rounded-lg bg-primary-foreground/15 px-3 py-2 text-sm">Live token estimates</span></div>
                </div>
                <Card className="shadow-sm">
                    <CardHeader><CardTitle>Book a care visit</CardTitle><CardDescription>Start with an online GP or choose a physical visit.</CardDescription></CardHeader>
                    <CardContent className="flex flex-col gap-4">
                        <label className="flex flex-col gap-1.5 text-sm font-medium">Patient name<Input value={patient_name} onChange={update_patient} placeholder="e.g. Nimali Perera" /></label>
                        <label className="flex flex-col gap-1.5 text-sm font-medium">District<select className="h-10 rounded-md border border-input bg-background px-3 text-sm" value={district} onChange={update_district}><option>Colombo</option><option>Ratnapura</option><option>Kandy</option><option>Galle</option></select></label>
                        <label className="flex flex-col gap-1.5 text-sm font-medium">Visit type<select className="h-10 rounded-md border border-input bg-background px-3 text-sm" value={visit_type} onChange={update_type}><option>Online GP</option><option>Physical specialist</option><option>Online specialist</option></select></label>
                        <Button onClick={book_visit} className="w-full">Confirm booking</Button>
                        {notice != "" and <p className="rounded-lg bg-primary/10 px-3 py-2 text-sm font-medium text-primary">{notice}</p>}
                        {error != "" and <p className="text-sm text-destructive">{error}</p>}
                    </CardContent>
                </Card>
            </section>
            <section className="flex flex-col gap-4">
                <div className="flex flex-wrap items-end justify-between gap-3"><div><h2 className="text-2xl font-semibold tracking-tight">Today's care queues</h2><p className="text-sm text-muted-foreground">Know the clinic status before you leave home.</p></div><span className="text-sm text-muted-foreground">Signed in as <strong className="text-foreground">{role}</strong></span></div>
                {loading and <Card><CardContent className="py-10 text-sm text-muted-foreground">Loading live queue…</CardContent></Card>}
                {not loading and len(rows) == 0 and <Card><CardContent className="py-10 text-center"><p className="font-medium">No queue updates yet</p><p className="mt-1 text-sm text-muted-foreground">Clinic availability will appear here.</p></CardContent></Card>}
                {not loading and len(rows) > 0 and <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">{for row in rows {
                    <Card key={row["name"] as str} className="shadow-sm transition-shadow hover:shadow-md"><CardHeader className="pb-3"><div className="flex items-start justify-between gap-3"><div><CardTitle className="text-base">{row["name"] as str}</CardTitle><CardDescription>{row["district"] as str} · {row["specialty"] as str}</CardDescription></div><Badge variant={"secondary" if (row["status"] as str) == "On time" else "outline"}>{row["status"] as str}</Badge></div></CardHeader><CardContent className="flex items-end justify-between border-t pt-4"><div><p className="text-xs text-muted-foreground">Current token</p><p className="text-2xl font-semibold tabular-nums">#{row["token"] as int}</p></div><div className="text-right"><p className="text-xs text-muted-foreground">Estimated delay</p><p className="font-medium tabular-nums">{str(row["delay"] as int)} min</p></div></CardContent></Card>
                }}</div>}
            </section>
            <footer className="flex flex-wrap items-center justify-between gap-2 border-t pt-4 text-xs text-muted-foreground"><span>SuwaSmart SL · Queue visibility for better care planning</span><span>Emergency: call 1990 for ambulance assistance</span></footer>
        </div>
    </main>;
}
