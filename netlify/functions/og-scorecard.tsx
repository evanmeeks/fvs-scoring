/**
 * Netlify Function: Dynamic OG Image for Scorecards
 * Generates Open Graph images for shared scorecards
 *
 * URL: /.netlify/functions/og-scorecard?targetId=X&userId=Y&targetName=Z&score=42
 */

import type { Handler, HandlerEvent } from "@netlify/functions";

export const handler: Handler = async (event: HandlerEvent) => {
  try {
    console.log('OG Scorecard function invoked with params:', event.queryStringParameters);

    // Dynamic import to avoid ES Module issues with esbuild
    const { ImageResponse } = await import("@vercel/og");

    const params = event.queryStringParameters || {};

    const targetName = params.targetName || 'Unknown Target'
    const score = params.score || '0'
    const totalVotes = params.totalVotes || '0'
    const _userName = params.userName || 'Anonymous'
    const _targetId = params.targetId || ''

    console.log('Parsed params:', { targetName, score, totalVotes });

    // Parse score (already 0-100 normalized scale)
    const scoreOutOf100 = Math.round(parseFloat(score))

    // Determine classification based on score (matching FVS classification logic)
    let _classification = 'UNSCORED'
    let classificationStatus = 'PENDING AUDIT'
    let scoreColor = '#9ca3af' // gray
    let badgeColor = '#6b7280'

    if (scoreOutOf100 >= 91) {
      _classification = 'STRATEGIC'
      classificationStatus = 'AUDITED // STRATEGIC'
      scoreColor = '#ffffff'
      badgeColor = '#ffffff'
    } else if (scoreOutOf100 >= 76) {
      _classification = 'HIGH-VALUE'
      classificationStatus = 'AUDITED // HIGH-VALUE'
      scoreColor = '#06b6d4'
      badgeColor = '#06b6d4'
    } else if (scoreOutOf100 >= 51) {
      _classification = 'LEGITIMATE'
      classificationStatus = 'AUDITED // LEGITIMATE'
      scoreColor = '#eab308'
      badgeColor = '#eab308'
    } else if (scoreOutOf100 >= 26) {
      _classification = 'AMBIGUOUS'
      classificationStatus = 'MIXED // AMBIGUOUS'
      scoreColor = '#f97316'
      badgeColor = '#f97316'
    } else if (scoreOutOf100 > 0) {
      _classification = 'OCCUPATION'
      classificationStatus = 'OCCUPATION'
      scoreColor = '#ef4444'
      badgeColor = '#ef4444'
    }

    // Font loading - Load Inter Bold (700 weight) since all text uses bold
    console.log('Fetching font...');
    const interBoldFont = await fetch(
      'https://fonts.gstatic.com/s/inter/v13/UcCO3FwrK3iLTeHuS_fvQtMwCp50KnMw2boKoduKmMEVuFuYAZ9hjp-Ek-_EeA.woff'
    ).then((res) => res.arrayBuffer())
    console.log('Font loaded successfully');

    const imageResponse = new ImageResponse(
      <div
        style={{
          height: '100%',
          width: '100%',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          backgroundColor: '#050505',
          backgroundImage: 'radial-gradient(circle at 25px 25px, #111 2%, transparent 0%), radial-gradient(circle at 75px 75px, #111 2%, transparent 0%)',
          backgroundSize: '100px 100px',
          padding: '80px',
          position: 'relative',
          fontFamily: '"Inter"',
        }}
      >
        {/* Main Card Container - Matching exact card design */}
        <div
          style={{
            display: 'flex',
            flexDirection: 'column',
            backgroundColor: '#0a0a0a',
            border: `1px solid ${scoreColor}80`,
            borderRadius: '12px',
            padding: '48px',
            width: '900px',
            justifyContent: 'space-between',
          }}
        >
          {/* Top Section */}
          <div style={{ display: 'flex', flexDirection: 'column' }}>
            {/* Header - Category Tag and Timestamp */}
            <div
              style={{
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'flex-start',
                marginBottom: '24px',
              }}
            >
              <div
                style={{
                  display: 'flex',
                  fontSize: '11px',
                  fontWeight: '400',
                  textTransform: 'uppercase',
                  backgroundColor: '#000000',
                  padding: '4px 12px',
                  borderRadius: '4px',
                  border: '1px solid #1f2937',
                  color: '#9ca3af',
                  letterSpacing: '0.5px',
                }}
              >
                MEDIA_BROADCAST
              </div>
              <div
                style={{
                  display: 'flex',
                  fontSize: '11px',
                  color: '#6b7280',
                  fontWeight: '400',
                }}
              >
                1 days ago
              </div>
            </div>

            {/* Target Name */}
            <div
              style={{
                display: 'flex',
                fontSize: '52px',
                fontWeight: '700',
                color: '#ffffff',
                marginBottom: '24px',
                lineHeight: 1.2,
              }}
            >
              {targetName}
            </div>

            {/* Classification Badge */}
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '8px',
                marginBottom: '32px',
              }}
            >
              <div
                style={{
                  display: 'flex',
                  fontSize: '13px',
                  fontWeight: '400',
                  color: badgeColor,
                  letterSpacing: '0.5px',
                }}
              >
                ✓ {classificationStatus}
              </div>
            </div>
          </div>

          {/* Bottom Section with Divider */}
          <div
            style={{
              display: 'flex',
              flexDirection: 'column',
              borderTop: '1px solid #1f2937',
              paddingTop: '32px',
            }}
          >
            <div
              style={{
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'center',
              }}
            >
              {/* Score Display */}
              <div
                style={{
                  display: 'flex',
                  fontSize: '80px',
                  fontWeight: '900',
                  color: scoreColor,
                  lineHeight: 1,
                }}
              >
                {scoreOutOf100}/100
              </div>

              {/* Metadata */}
              <div
                style={{
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'flex-end',
                  gap: '8px',
                }}
              >
                <div
                  style={{
                    display: 'flex',
                    fontSize: '13px',
                    color: '#9ca3af',
                    textTransform: 'uppercase',
                    letterSpacing: '1px',
                  }}
                >
                  {totalVotes} NETWORK VOTES
                </div>
                <div
                  style={{
                    display: 'flex',
                    fontSize: '11px',
                    color: '#6b7280',
                  }}
                >
                  Global Consensus
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Footer Branding */}
        <div
          style={{
            display: 'flex',
            position: 'absolute',
            bottom: '40px',
            fontSize: '16px',
            color: '#6b7280',
            letterSpacing: '2px',
            textTransform: 'uppercase',
          }}
        >
          FORECASTAUDIT.PRO
        </div>
      </div>,
      {
        width: 1200,
        height: 630,
        fonts: [
          {
            name: 'Inter',
            data: interBoldFont,
            style: 'normal',
            weight: 700,
          },
        ],
      }
    );

    const pngBuffer = await imageResponse.arrayBuffer();

    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'image/png',
        'Cache-Control': 'public, max-age=31536000, immutable',
      },
      body: Buffer.from(pngBuffer).toString('base64'),
      isBase64Encoded: true,
    };
  } catch (error) {
    console.error('OG Image generation error:', error);
    console.error('Error stack:', error instanceof Error ? error.stack : 'No stack trace');
    console.error('Error message:', error instanceof Error ? error.message : String(error));
    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        error: 'Failed to generate image',
        message: error instanceof Error ? error.message : String(error),
        stack: error instanceof Error ? error.stack : undefined,
      }),
    };
  }
};
