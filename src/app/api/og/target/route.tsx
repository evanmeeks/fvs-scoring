import { ImageResponse } from "@vercel/og";
import { type NextRequest } from "next/server";

export const runtime = "edge";

export async function GET(request: NextRequest) {
  const { searchParams } = request.nextUrl;

  const targetName = searchParams.get("targetName") ?? "Target Proposal";
  const caseId = searchParams.get("caseId") ?? "";
  const author = searchParams.get("author") ?? "Anonymous";
  const origin = searchParams.get("origin") ?? "";

  const interBoldFont = await fetch(
    "https://fonts.gstatic.com/s/inter/v13/UcCO3FwrK3iLTeHuS_fvQtMwCp50KnMw2boKoduKmMEVuFuYAZ9hjp-Ek-_EeA.woff",
  ).then((res) => res.arrayBuffer());

  return new ImageResponse(
    (
      <div
        style={{
          height: "100%",
          width: "100%",
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          justifyContent: "center",
          backgroundColor: "#050505",
          backgroundImage:
            "radial-gradient(circle at 25px 25px, #111 2%, transparent 0%), radial-gradient(circle at 75px 75px, #111 2%, transparent 0%)",
          backgroundSize: "100px 100px",
          padding: "60px",
          position: "relative",
          fontFamily: '"Inter"',
        }}
      >
        {caseId && (
          <div
            style={{
              position: "absolute",
              top: "40px",
              right: "60px",
              display: "flex",
              alignItems: "center",
              backgroundColor: "#1e3a8a",
              border: "2px solid #3b82f6",
              padding: "12px 24px",
              borderRadius: "8px",
            }}
          >
            <div
              style={{
                fontSize: "20px",
                fontWeight: "700",
                color: "#3b82f6",
                letterSpacing: "1px",
              }}
            >
              {caseId}
            </div>
          </div>
        )}

        <div
          style={{
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            marginBottom: "40px",
          }}
        >
          <div
            style={{
              fontSize: "28px",
              fontWeight: "600",
              color: "#9ca3af",
              marginBottom: "8px",
              letterSpacing: "2px",
              textTransform: "uppercase",
            }}
          >
            Target Proposal
          </div>
          <div
            style={{
              fontSize: "16px",
              color: "#6b7280",
              letterSpacing: "1px",
            }}
          >
            Forecast Audit
          </div>
        </div>

        <div
          style={{
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            maxWidth: "900px",
            textAlign: "center",
            marginBottom: "30px",
          }}
        >
          <div
            style={{
              fontSize: "48px",
              fontWeight: "700",
              color: "#fff",
              lineHeight: 1.2,
              marginBottom: "16px",
            }}
          >
            {targetName}
          </div>
          {origin && (
            <div
              style={{
                fontSize: "28px",
                color: "#8b5cf6",
                marginBottom: "16px",
              }}
            >
              {origin}
            </div>
          )}
          <div
            style={{
              fontSize: "24px",
              color: "#9ca3af",
            }}
          >
            Proposed by {author}
          </div>
        </div>

        <div
          style={{
            position: "absolute",
            bottom: "40px",
            fontSize: "18px",
            color: "#6b7280",
          }}
        >
          forecastaudit.pro
        </div>
      </div>
    ),
    {
      width: 1200,
      height: 630,
      fonts: [
        {
          name: "Inter",
          data: interBoldFont,
          style: "normal",
          weight: 700,
        },
      ],
    },
  );
}
