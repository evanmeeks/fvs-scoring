import { ImageResponse } from "@vercel/og";
import { type NextRequest } from "next/server";

export const runtime = "edge";

export async function GET(request: NextRequest) {
  const { searchParams } = request.nextUrl;

  const title = searchParams.get("title") ?? "RFC Proposal";
  const status = searchParams.get("status") ?? "draft";
  const votesFor = searchParams.get("votesFor") ?? "0";
  const votesAgainst = searchParams.get("votesAgainst") ?? "0";
  const author = searchParams.get("author") ?? "Anonymous";

  let statusColor = "#6b7280";
  let statusBg = "#1f2937";
  let statusText = "DRAFT";

  switch (status.toLowerCase()) {
    case "active":
      statusColor = "#06b6d4";
      statusBg = "#164e63";
      statusText = "ACTIVE";
      break;
    case "approved":
      statusColor = "#10b981";
      statusBg = "#064e3b";
      statusText = "APPROVED";
      break;
    case "rejected":
      statusColor = "#ef4444";
      statusBg = "#7f1d1d";
      statusText = "REJECTED";
      break;
    case "pending":
      statusColor = "#f59e0b";
      statusBg = "#78350f";
      statusText = "PENDING";
      break;
  }

  const totalVotes = parseInt(votesFor) + parseInt(votesAgainst);

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
        {/* Status Badge */}
        <div
          style={{
            position: "absolute",
            top: "40px",
            right: "60px",
            display: "flex",
            alignItems: "center",
            backgroundColor: statusBg,
            border: `2px solid ${statusColor}`,
            padding: "12px 24px",
            borderRadius: "8px",
          }}
        >
          <div
            style={{
              fontSize: "20px",
              fontWeight: "700",
              color: statusColor,
              letterSpacing: "2px",
            }}
          >
            {statusText}
          </div>
        </div>

        {/* Header */}
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
            RFC Proposal
          </div>
          <div
            style={{
              fontSize: "16px",
              color: "#6b7280",
              letterSpacing: "1px",
            }}
          >
            Forecast Audit Governance
          </div>
        </div>

        {/* Title */}
        <div
          style={{
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            maxWidth: "900px",
            textAlign: "center",
            marginBottom: "50px",
          }}
        >
          <div
            style={{
              fontSize: "48px",
              fontWeight: "700",
              color: "#fff",
              lineHeight: 1.2,
              marginBottom: "20px",
            }}
          >
            {title}
          </div>
          <div style={{ fontSize: "22px", color: "#9ca3af" }}>
            Proposed by {author}
          </div>
        </div>

        {/* Voting Stats */}
        {totalVotes > 0 && (
          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: "40px",
              marginTop: "20px",
            }}
          >
            <div
              style={{
                display: "flex",
                flexDirection: "column",
                alignItems: "center",
              }}
            >
              <div
                style={{ fontSize: "48px", fontWeight: "700", color: "#10b981" }}
              >
                {votesFor}
              </div>
              <div style={{ fontSize: "18px", color: "#6b7280" }}>FOR</div>
            </div>
            <div
              style={{
                width: "2px",
                height: "60px",
                backgroundColor: "#374151",
              }}
            />
            <div
              style={{
                display: "flex",
                flexDirection: "column",
                alignItems: "center",
              }}
            >
              <div
                style={{ fontSize: "48px", fontWeight: "700", color: "#ef4444" }}
              >
                {votesAgainst}
              </div>
              <div style={{ fontSize: "18px", color: "#6b7280" }}>AGAINST</div>
            </div>
          </div>
        )}

        {/* Footer */}
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
