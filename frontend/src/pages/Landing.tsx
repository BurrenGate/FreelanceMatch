import { Link } from "react-router-dom";
import { Button } from "@/components/ui/button";
import {
  ArrowRight,
  BadgeCheck,
  BriefcaseBusiness,
  CheckCircle2,
  Clock3,
  CreditCard,
  FileSignature,
  Search,
  ShieldCheck,
  Sparkles,
  Star,
  Users,
} from "lucide-react";

const metrics = [
  { value: "48h", label: "average shortlist time" },
  { value: "92%", label: "contracts completed on scope" },
  { value: "4.9/5", label: "average freelancer rating" },
];

const features = [
  {
    icon: Search,
    title: "Skill-aware matching",
    description:
      "Match jobs with freelancers by verified skills, availability, rating, and proposal quality.",
  },
  {
    icon: FileSignature,
    title: "Contracts without chaos",
    description:
      "Move from accepted proposal to contract, job status, payment, and review in one clean workflow.",
  },
  {
    icon: ShieldCheck,
    title: "Protected execution",
    description:
      "Role-based actions, structured status transitions, and database-level business rules keep work reliable.",
  },
];

const workflow = [
  "Publish a job with required skills",
  "Review matched proposals",
  "Accept the best freelancer",
  "Complete, pay, and review",
];

const trustItems = [
  "JWT-secured accounts",
  "Role-specific dashboards",
  "Atomic contract completion",
  "Admin-managed directories",
];

export default function Landing() {
  return (
    <div className="flex flex-col bg-[#f7f4ee] text-[#151515]">
      <section className="relative min-h-[calc(100vh-4rem)] overflow-hidden">
        <div className="pointer-events-none absolute -left-24 top-20 h-64 w-64 rounded-full bg-[#f4c95d]/25 blur-3xl animate-pulse" />
        <div className="pointer-events-none absolute bottom-16 right-8 h-72 w-72 rounded-full bg-[#22c55e]/20 blur-3xl animate-pulse [animation-delay:700ms]" />
        <img
          src="https://images.unsplash.com/photo-1556761175-b413da4baf72?auto=format&fit=crop&w=2400&q=85"
          alt="A professional team planning freelance project work around a desk"
          className="absolute inset-0 h-full w-full object-cover motion-safe:animate-in motion-safe:fade-in-0 motion-safe:duration-700"
        />
        <div className="absolute inset-0 bg-[linear-gradient(90deg,rgba(10,18,18,0.92)_0%,rgba(10,18,18,0.78)_42%,rgba(10,18,18,0.32)_100%)]" />
        <div className="absolute inset-x-0 bottom-0 h-32 bg-gradient-to-t from-[#f7f4ee] to-transparent" />

        <div className="container relative mx-auto flex min-h-[calc(100vh-4rem)] items-center px-4 py-16 md:py-20">
          <div className="max-w-3xl pt-6 text-white motion-safe:animate-in motion-safe:fade-in-0 motion-safe:slide-in-from-bottom-6 motion-safe:duration-700">
            <div className="mb-6 inline-flex items-center gap-2 rounded-full border border-white/20 bg-white/10 px-4 py-2 text-sm font-semibold text-white shadow-2xl backdrop-blur-md motion-safe:animate-in motion-safe:fade-in-0 motion-safe:duration-700 motion-safe:[animation-delay:120ms]">
              <Sparkles className="h-4 w-4 text-[#f4c95d]" />
              Freelance marketplace for serious delivery
            </div>

            <h1 className="max-w-3xl text-5xl font-black leading-[0.98] tracking-normal md:text-7xl lg:text-8xl motion-safe:animate-in motion-safe:fade-in-0 motion-safe:slide-in-from-left-4 motion-safe:duration-700 motion-safe:[animation-delay:180ms]">
              Freelance Matcher
            </h1>

            <p className="mt-7 max-w-2xl text-lg leading-8 text-white/80 md:text-xl motion-safe:animate-in motion-safe:fade-in-0 motion-safe:slide-in-from-left-4 motion-safe:duration-700 motion-safe:[animation-delay:250ms]">
              Connect clients with the right freelancers, turn proposals into
              contracts, and keep payments, reviews, and project status moving
              through one professional workflow.
            </p>

            <div className="mt-9 flex flex-col gap-3 sm:flex-row motion-safe:animate-in motion-safe:fade-in-0 motion-safe:slide-in-from-bottom-4 motion-safe:duration-700 motion-safe:[animation-delay:320ms]">
              <Button
                size="lg"
                asChild
                className="h-12 rounded-md bg-[#f4c95d] px-6 font-bold text-[#151515] shadow-xl shadow-black/20 hover:bg-[#ffd875]"
              >
                <Link to="/register">
                  Start matching
                  <ArrowRight className="ml-2 h-4 w-4" />
                </Link>
              </Button>
              <Button
                size="lg"
                variant="outline"
                asChild
                className="h-12 rounded-md border-white/30 bg-white/10 px-6 font-bold text-white backdrop-blur-md hover:bg-white hover:text-[#151515]"
              >
                <Link to="/login">Sign in</Link>
              </Button>
            </div>

            <div className="mt-12 grid max-w-2xl grid-cols-1 gap-3 sm:grid-cols-3 motion-safe:animate-in motion-safe:fade-in-0 motion-safe:slide-in-from-bottom-4 motion-safe:duration-700 motion-safe:[animation-delay:420ms]">
              {metrics.map((metric) => (
                <div
                  key={metric.label}
                  className="border-l border-white/20 pl-4 text-left"
                >
                  <div className="text-3xl font-black text-white">
                    {metric.value}
                  </div>
                  <div className="mt-1 text-sm leading-5 text-white/70">
                    {metric.label}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      <section className="border-y border-[#151515]/10 bg-[#f7f4ee] py-5 motion-safe:animate-in motion-safe:fade-in-0 motion-safe:duration-700">
        <div className="container mx-auto grid gap-3 px-4 sm:grid-cols-2 lg:grid-cols-4">
          {trustItems.map((item) => (
            <div
              key={item}
              className="flex items-center gap-2 text-sm font-bold text-[#151515]/70"
            >
              <CheckCircle2 className="h-4 w-4 text-[#0f766e]" />
              {item}
            </div>
          ))}
        </div>
      </section>

      <section className="bg-[#f7f4ee] py-20 md:py-28 motion-safe:animate-in motion-safe:fade-in-0 motion-safe:slide-in-from-bottom-3 motion-safe:duration-700">
        <div className="container mx-auto px-4">
          <div className="grid gap-12 lg:grid-cols-[0.95fr_1.05fr] lg:items-end">
            <div>
              <p className="text-sm font-black uppercase tracking-[0.18em] text-[#0f766e]">
                Built for marketplace operations
              </p>
              <h2 className="mt-4 max-w-2xl text-4xl font-black tracking-normal text-[#151515] md:text-5xl">
                From first proposal to final review, every step has a place.
              </h2>
            </div>
            <p className="max-w-2xl text-lg leading-8 text-[#151515]/70">
              Freelance Matcher gives clients clarity, freelancers momentum,
              and admins the controls needed to keep the marketplace clean:
              roles, skills, job statuses, transactions, and reviews.
            </p>
          </div>

          <div className="mt-12 grid gap-4 md:grid-cols-3">
            {features.map((feature) => (
              <article
                key={feature.title}
                className="rounded-lg border border-[#151515]/10 bg-white p-7 shadow-[0_18px_45px_rgba(21,21,21,0.08)] transition-all duration-300 hover:-translate-y-1 hover:shadow-[0_22px_55px_rgba(21,21,21,0.14)] motion-safe:animate-in motion-safe:fade-in-0 motion-safe:slide-in-from-bottom-2"
              >
                <div className="mb-6 inline-flex h-12 w-12 items-center justify-center rounded-md bg-[#123c3a] text-[#f4c95d]">
                  <feature.icon className="h-6 w-6" />
                </div>
                <h3 className="text-xl font-black tracking-normal text-[#151515]">
                  {feature.title}
                </h3>
                <p className="mt-3 text-sm leading-7 text-[#151515]/60">
                  {feature.description}
                </p>
              </article>
            ))}
          </div>
        </div>
      </section>

      <section className="bg-[#123c3a] py-20 text-white md:py-24 motion-safe:animate-in motion-safe:fade-in-0 motion-safe:slide-in-from-bottom-3 motion-safe:duration-700">
        <div className="container mx-auto grid gap-12 px-4 lg:grid-cols-[0.85fr_1.15fr] lg:items-center">
          <div>
            <div className="inline-flex items-center gap-2 rounded-full bg-white/10 px-4 py-2 text-sm font-bold text-[#f4c95d]">
              <Clock3 className="h-4 w-4" />
              Workflow designed for speed
            </div>
            <h2 className="mt-6 max-w-xl text-4xl font-black tracking-normal md:text-5xl">
              A calmer way to run freelance work.
            </h2>
            <p className="mt-5 max-w-xl text-base leading-8 text-white/70">
              Clients get the structure they need to hire confidently.
              Freelancers get a clear path from proposal to paid work.
            </p>
          </div>

          <div className="grid gap-3">
            {workflow.map((step, index) => (
              <div
                key={step}
                className="grid grid-cols-[3rem_1fr_auto] items-center gap-4 rounded-lg border border-white/10 bg-white/[0.06] p-4 backdrop-blur transition-colors duration-300 hover:bg-white/[0.12] motion-safe:animate-in motion-safe:fade-in-0 motion-safe:slide-in-from-right-2"
              >
                <div className="flex h-12 w-12 items-center justify-center rounded-md bg-[#f4c95d] text-lg font-black text-[#151515]">
                  {index + 1}
                </div>
                <div className="font-bold text-white">{step}</div>
                <ArrowRight className="hidden h-5 w-5 text-white/50 sm:block" />
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className="bg-white py-20 md:py-24 motion-safe:animate-in motion-safe:fade-in-0 motion-safe:slide-in-from-bottom-3 motion-safe:duration-700">
        <div className="container mx-auto px-4">
          <div className="grid gap-4 md:grid-cols-3">
            <div className="rounded-lg bg-[#f7f4ee] p-7">
              <BriefcaseBusiness className="h-8 w-8 text-[#0f766e]" />
              <h3 className="mt-5 text-2xl font-black tracking-normal">
                For clients
              </h3>
              <p className="mt-3 text-sm leading-7 text-[#151515]/60">
                Publish jobs, manage required skills, compare proposals, and
                move work into contracts with confidence.
              </p>
            </div>
            <div className="rounded-lg bg-[#f7f4ee] p-7">
              <Users className="h-8 w-8 text-[#0f766e]" />
              <h3 className="mt-5 text-2xl font-black tracking-normal">
                For freelancers
              </h3>
              <p className="mt-3 text-sm leading-7 text-[#151515]/60">
                Build a skill-rich profile, find relevant jobs, send proposals,
                and track contracts, earnings, and reviews.
              </p>
            </div>
            <div className="rounded-lg bg-[#f7f4ee] p-7">
              <CreditCard className="h-8 w-8 text-[#0f766e]" />
              <h3 className="mt-5 text-2xl font-black tracking-normal">
                For admins
              </h3>
              <p className="mt-3 text-sm leading-7 text-[#151515]/60">
                Keep marketplace data healthy with managed roles, skills, job
                statuses, transactions, and reviews.
              </p>
            </div>
          </div>
        </div>
      </section>

      <section className="bg-[#151515] py-16 text-white motion-safe:animate-in motion-safe:fade-in-0 motion-safe:duration-700">
        <div className="container mx-auto flex flex-col gap-8 px-4 md:flex-row md:items-center md:justify-between">
          <div>
            <div className="flex items-center gap-2 text-sm font-bold text-[#f4c95d]">
              <Star className="h-4 w-4 fill-[#f4c95d]" />
              Freelance Matcher is ready for your next project flow
            </div>
            <h2 className="mt-3 max-w-2xl text-3xl font-black tracking-normal md:text-4xl">
              Start with a job. Finish with a paid contract and a verified
              review.
            </h2>
          </div>
          <Button
            size="lg"
            asChild
            className="h-12 rounded-md bg-white px-6 font-bold text-[#151515] hover:bg-[#f4c95d]"
          >
            <Link to="/register">
              Create account
              <BadgeCheck className="ml-2 h-4 w-4" />
            </Link>
          </Button>
        </div>
      </section>
    </div>
  );
}
