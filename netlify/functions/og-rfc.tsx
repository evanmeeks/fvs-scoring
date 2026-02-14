/**
 * Netlify Function: Dynamic OG Image for RFC Proposals
 * Generates Open Graph images for RFC proposals
 *
 * URL: /.netlify/functions/og-rfc?title=X&status=Y&votes=Z
 */

import type { Handler, HandlerEvent } from "@netlify/functions";

export const handler: Handler = async (event: HandlerEvent) => {
  try {
    // Dynamic import to avoid ES Module issues with esbuild
    const { ImageResponse } = await import("@vercel/og");

    const params = event.queryStringParameters || {};

    const title = params.title || "RFC Proposal";
    const status = params.status || "draft";
    const votesFor = params.votesFor || "0";
    const votesAgainst = params.votesAgainst || "0";
    const author = params.author || "Anonymous";

    // Determine status color and badge
    let statusColor = "#6b7280"; // gray (draft)
    let statusBg = "#1f2937";
    let statusText = "DRAFT";

    switch (status.toLowerCase()) {
      case "active":
        statusColor = "#06b6d4"; // cyan
        statusBg = "#164e63";
        statusText = "ACTIVE";
        break;
      case "approved":
        statusColor = "#10b981"; // green
        statusBg = "#064e3b";
        statusText = "APPROVED";
        break;
      case "rejected":
        statusColor = "#ef4444"; // red
        statusBg = "#7f1d1d";
        statusText = "REJECTED";
        break;
      case "pending":
        statusColor = "#f59e0b"; // amber
        statusBg = "#78350f";
        statusText = "PENDING";
        break;
    }

    const totalVotes = parseInt(votesFor) + parseInt(votesAgainst);
    const _votesForPercent =
      totalVotes > 0 ? (parseInt(votesFor) / totalVotes) * 100 : 0;

    // Font loading - Load Inter Bold (700 weight)
    const interBoldFont = await fetch(
      "https://fonts.gstatic.com/s/inter/v13/UcCO3FwrK3iLTeHuS_fvQtMwCp50KnMw2boKoduKmMEVuFuYAZ9hjp-Ek-_EeA.woff"
    ).then((res) => res.arrayBuffer());

    const imageResponse = new ImageResponse(
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

        {/* RFC Title */}
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
          <div
            style={{
              fontSize: "22px",
              color: "#9ca3af",
            }}
          >
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
                style={{
                  fontSize: "48px",
                  fontWeight: "700",
                  color: "#10b981",
                }}
              >
                {votesFor}
              </div>
              <div
                style={{
                  fontSize: "18px",
                  color: "#6b7280",
                }}
              >
                FOR
              </div>
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
                style={{
                  fontSize: "48px",
                  fontWeight: "700",
                  color: "#ef4444",
                }}
              >
                {votesAgainst}
              </div>
              <div
                style={{
                  fontSize: "18px",
                  color: "#6b7280",
                }}
              >
                AGAINST
              </div>
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
      </div>,
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

    const pngBuffer = await imageResponse.arrayBuffer();

    return {
      statusCode: 200,
      headers: {
        "Content-Type": "image/png",
        "Cache-Control": "public, max-age=31536000, immutable",
      },
      body: Buffer.from(pngBuffer).toString("base64"),
      isBase64Encoded: true,
    };
  } catch (error) {
    console.error("OG Image generation error:", error);
    return {
      statusCode: 500,
      body: "Failed to generate image",
    };
  }
};
