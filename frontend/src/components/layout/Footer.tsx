import { Briefcase } from "lucide-react";

export function Footer() {
  return (
    <footer className="border-t bg-card">
      <div className="container mx-auto flex flex-col md:flex-row items-center justify-between gap-4 px-4 py-8">
        <div className="flex items-center gap-2 font-semibold text-foreground">
          <div className="bg-primary p-1 rounded-md">
            <Briefcase className="w-3.5 h-3.5 text-primary-foreground" />
          </div>
          Freelance Matcher
        </div>
        <p className="text-sm text-muted-foreground">
          © {new Date().getFullYear()} Freelance Matcher. All rights reserved.
        </p>
      </div>
    </footer>
  );
}
