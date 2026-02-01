import "~/styles/globals.css";

import { type Metadata } from "next";
import { Inter } from "next/font/google";

import { AppContextProvider } from "~/context/AppContext";
import Header from "~/components/Header";
import DashboardShell from "~/components/DashboardShell";

const inter = Inter({
  subsets: ["latin"],
  variable: "--font-inter",
});

export const metadata: Metadata = {
  title: {
    default: "Forecast Audit",
    template: "%s | Forecast Audit",
  },
  description:
    "Forecast Audit — a collaborative framework for evaluating media claims and predictions using key quality metrics.",
  metadataBase: new URL("https://forecastaudit.pro"),
  openGraph: {
    type: "website",
    siteName: "Forecast Audit",
    title: "Forecast Audit",
    description:
      "A collaborative framework for evaluating media claims and predictions using key quality metrics.",
    url: "https://forecastaudit.pro",
    images: [{ url: "/og-image.png", width: 1200, height: 630 }],
  },
  twitter: {
    card: "summary_large_image",
    title: "Forecast Audit",
    description:
      "A collaborative framework for evaluating media claims and predictions using key quality metrics.",
  },
  icons: [{ rel: "icon", url: "/favicon.ico" }],
  robots: {
    index: true,
    follow: true,
  },
};

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en" className={`dark ${inter.variable}`}>
      <head>
        <link
          rel="stylesheet"
          href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200"
        />
      </head>
      <body className="min-h-screen bg-background font-sans antialiased">
        <AppContextProvider>
          <div className="h-screen flex flex-col overflow-hidden">
            <Header />
            <DashboardShell>{children}</DashboardShell>
          </div>
        </AppContextProvider>
      </body>
    </html>
  );
}
