/**
 * Netlify Function: Dynamic OG Image for Target Submissions
 * Generates Open Graph images for proposed targets
 *
 * URL: /.netlify/functions/og-target?targetName=X&caseId=Y&author=Z
 */

import type { Handler, HandlerEvent } from "@netlify/functions";

export const handler: Handler = async (event: HandlerEvent) => {
  try {
    // Dynamic import to avoid ES Module issues with esbuild
    const { ImageResponse } = await import("@vercel/og");

    const params = event.queryStringParameters || {};

    const targetName = params.targetName || 'Target Proposal'
    const caseId = params.caseId || ''
    const author = params.author || 'Anonymous'
    const origin = params.origin || ''

    // Font loading - Load Inter Bold (700 weight)
    const interBoldFont = await fetch(
      'https://fonts.gstatic.com/s/inter/v13/UcCO3FwrK3iLTeHuS_fvQtMwCp50KnMw2boKoduKmMEVuFuYAZ9hjp-Ek-_EeA.woff'
    ).then((res) => res.arrayBuffer())

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
            padding: '60px',
            position: 'relative',
            fontFamily: '"Inter"',
          }}
        >
          {/* Case ID Badge */}
          {caseId && (
            <div
              style={{
                position: 'absolute',
                top: '40px',
                right: '60px',
                display: 'flex',
                alignItems: 'center',
                backgroundColor: '#1e3a8a',
                border: '2px solid #3b82f6',
                padding: '12px 24px',
                borderRadius: '8px',
              }}
            >
              <div
                style={{
                  fontSize: '20px',
                  fontWeight: '700',
                  color: '#3b82f6',
                  letterSpacing: '1px',
                }}
              >
                {caseId}
              </div>
            </div>
          )}

          {/* Header */}
          <div
            style={{
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              marginBottom: '40px',
            }}
          >
            <div
              style={{
                fontSize: '28px',
                fontWeight: '600',
                color: '#9ca3af',
                marginBottom: '8px',
                letterSpacing: '2px',
                textTransform: 'uppercase',
              }}
            >
              Target Proposal
            </div>
            <div
              style={{
                fontSize: '16px',
                color: '#6b7280',
                letterSpacing: '1px',
              }}
            >
              FVS Scoring Target
            </div>
          </div>

          {/* Icon */}
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              width: '120px',
              height: '120px',
              borderRadius: '50%',
              border: '4px solid #8b5cf6',
              marginBottom: '40px',
              backgroundColor: '#2e1065',
              boxShadow: '0 0 40px #8b5cf640',
            }}
          >
            <div
              style={{
                fontSize: '64px',
              }}
            >
              🎯
            </div>
          </div>

          {/* Target Name */}
          <div
            style={{
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              maxWidth: '900px',
              textAlign: 'center',
              marginBottom: '30px',
            }}
          >
            <div
              style={{
                fontSize: '48px',
                fontWeight: '700',
                color: '#fff',
                lineHeight: 1.2,
                marginBottom: '16px',
              }}
            >
              {targetName}
            </div>
            {origin && (
              <div
                style={{
                  fontSize: '28px',
                  color: '#8b5cf6',
                  marginBottom: '16px',
                }}
              >
                {origin}
              </div>
            )}
            <div
              style={{
                fontSize: '24px',
                color: '#9ca3af',
              }}
            >
              Proposed by {author}
            </div>
          </div>

          {/* Footer */}
          <div
            style={{
              position: 'absolute',
              bottom: '40px',
              fontSize: '18px',
              color: '#6b7280',
            }}
          >
            fvs-metrics.com
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
    console.error('OG Image generation error:', error)
    return {
      statusCode: 500,
      body: 'Failed to generate image',
    };
  }
};
