import { ImageResponse } from "@vercel/og";
import { type NextRequest } from "next/server";

export const runtime = "edge";

export async function GET(request: NextRequest) {
  const { searchParams } = request.nextUrl;

  const targetName = searchParams.get("targetName") ?? "Unknown Target";
  const score = searchParams.get("score") ?? "0";
  const totalVotes = searchParams.get("totalVotes") ?? "0";

  const scoreOutOf100 = Math.round(parseFloat(score));

  let classificationStatus = "PENDING AUDIT";
  let scoreColor = "#9ca3af";
  let badgeColor = "#6b7280";

  if (scoreOutOf100 >= 91) {
    classificationStatus = "CONSENSUS FORECAST";
    scoreColor = "#ffffff";
    badgeColor = "#ffffff";
  } else if (scoreOutOf100 >= 76) {
    classificationStatus = "HIGH-CONFIDENCE FORECAST";
    scoreColor = "#06b6d4";
    badgeColor = "#06b6d4";
  } else if (scoreOutOf100 >= 51) {
    classificationStatus = "CREDIBLE FORECAST";
    scoreColor = "#eab308";
    badgeColor = "#eab308";
  } else if (scoreOutOf100 >= 26) {
    classificationStatus = "SPECULATIVE";
    scoreColor = "#f97316";
    badgeColor = "#f97316";
  } else if (scoreOutOf100 > 0) {
    classificationStatus = "LOW CONFIDENCE";
    scoreColor = "#ef4444";
    badgeColor = "#ef4444";
  }

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
          padding: "80px",
          position: "relative",
          fontFamily: '"Inter"',
        }}
      >
        <div
          style={{
            display: "flex",
            flexDirection: "column",
            backgroundColor: "#0a0a0a",
            border: `1px solid ${scoreColor}80`,
            borderRadius: "12px",
            padding: "48px",
            width: "900px",
            justifyContent: "space-between",
          }}
        >
          <div style={{ display: "flex", flexDirection: "column" }}>
            <div
              style={{
                display: "flex",
                justifyContent: "space-between",
                alignItems: "flex-start",
                marginBottom: "24px",
              }}
            >
              <div
                style={{
                  display: "flex",
                  fontSize: "11px",
                  fontWeight: "400",
                  textTransform: "uppercase",
                  backgroundColor: "#000000",
                  padding: "4px 12px",
                  borderRadius: "4px",
                  border: "1px solid #1f2937",
                  color: "#9ca3af",
                  letterSpacing: "0.5px",
                }}
              >
                FORECAST AUDIT
              </div>
            </div>

            <div
              style={{
                display: "flex",
                fontSize: "52px",
                fontWeight: "700",
                color: "#ffffff",
                marginBottom: "24px",
                lineHeight: 1.2,
              }}
            >
              {targetName}
            </div>

            <div
              style={{
                display: "flex",
                alignItems: "center",
                gap: "8px",
                marginBottom: "32px",
              }}
            >
              <div
                style={{
                  display: "flex",
                  fontSize: "13px",
                  fontWeight: "400",
                  color: badgeColor,
                  letterSpacing: "0.5px",
                }}
              >
                ✓ {classificationStatus}
              </div>
            </div>
          </div>

          <div
            style={{
              display: "flex",
              flexDirection: "column",
              borderTop: "1px solid #1f2937",
              paddingTop: "32px",
            }}
          >
            <div
              style={{
                display: "flex",
                justifyContent: "space-between",
                alignItems: "center",
              }}
            >
              <div
                style={{
                  display: "flex",
                  fontSize: "80px",
                  fontWeight: "900",
                  color: scoreColor,
                  lineHeight: 1,
                }}
              >
                {scoreOutOf100}/100
              </div>

              <div
                style={{
                  display: "flex",
                  flexDirection: "column",
                  alignItems: "flex-end",
                  gap: "8px",
                }}
              >
                <div
                  style={{
                    display: "flex",
                    fontSize: "13px",
                    color: "#9ca3af",
                    textTransform: "uppercase",
                    letterSpacing: "1px",
                  }}
                >
                  {totalVotes} NETWORK VOTES
                </div>
                <div
                  style={{
                    display: "flex",
                    fontSize: "11px",
                    color: "#6b7280",
                  }}
                >
                  Global Consensus
                </div>
              </div>
            </div>
          </div>
        </div>

        <div
          style={{
            display: "flex",
            position: "absolute",
            bottom: "40px",
            fontSize: "16px",
            color: "#6b7280",
            letterSpacing: "2px",
            textTransform: "uppercase",
          }}
        >
          FORECASTAUDIT.PRO
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
