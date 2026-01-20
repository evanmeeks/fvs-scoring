
import { createFileRoute } from '@tanstack/react-router'
import { SharedScorecardView } from '../components/views/SharedScorecardView'
import { createSharedScorecardHeadConfig } from '../utils/seo'
import { LandingView } from '../components/views/LandingView'
import { supabase } from '../utils/supabase'

export const Route = createFileRoute('/share/scorecard/$targetId/$userId')({
    loader: async ({ params }) => {
        const { targetId, userId } = params

        // Fetch target details
        const { data: target } = await supabase
            .from('targets')
            .select('id, name, case_id')
            .eq('id', targetId)
            .single()

        // Fetch user profile
        const { data: profile } = await supabase
            .from('profiles')
            .select('display_name, username, full_name')
            .eq('id', userId)
            .single()

        // Fetch user's votes for this target
        const { data: votes } = await supabase
            .from('votes')
            .select('vote_value')
            .eq('target_id', targetId)
            .eq('user_id', userId)

        // Calculate average score
        const avgScore = votes && votes.length > 0
            ? votes.reduce((sum, v) => sum + v.vote_value, 0) / votes.length
            : 0

        return {
            target,
            profile,
            avgScore,
            votesCount: votes?.length || 0,
        }
    },

    head: ({ params, loaderData }) => {
        // Fallback for when data isn't available
        if (!loaderData?.target) {
            return createSharedScorecardHeadConfig({
                targetId: params.targetId,
                userId: params.userId,
                targetName: 'FVS Scorecard',
                score: 0,
            })
        }

        const userName = loaderData.profile?.display_name
            || loaderData.profile?.full_name
            || loaderData.profile?.username
            || 'Anonymous'

        return createSharedScorecardHeadConfig({
            targetId: params.targetId,
            userId: params.userId,
            targetName: loaderData.target.name,
            userName,
            score: loaderData.avgScore,
        })
    },

    component: SharedScorecardComponent,
})

function SharedScorecardComponent() {
    const { targetId, userId } = Route.useParams()

    return (
        <LandingView>
            <SharedScorecardView targetId={targetId} userId={userId} />
        </LandingView>
    )
}
