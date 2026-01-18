import { renderHook, act, waitFor } from '@testing-library/react';
import { useAuth, useGovernanceVote, useSubmitComment, useVoteOnComment, useUserScores, useDiscussions } from '../useSupabase';
import { supabase } from '../../utils/supabase';
import { vi, describe, it, expect, beforeEach } from 'vitest';

// Mock supabase client
vi.mock('../../utils/supabase', () => ({
    supabase: {
        auth: {
            getSession: vi.fn(),
            onAuthStateChange: vi.fn(),
            signInWithPassword: vi.fn(),
            signOut: vi.fn(),
            getUser: vi.fn(),
        },
        from: vi.fn(() => ({
            upsert: vi.fn(() => ({
                select: vi.fn(() => ({
                    data: null,
                    error: null
                }))
            })),
            select: vi.fn(() => ({
                eq: vi.fn(() => ({
                    is: vi.fn(() => ({
                        order: vi.fn().mockResolvedValue({ data: [], error: null })
                    })),
                    order: vi.fn().mockResolvedValue({ data: [], error: null })
                }))
            })),
            insert: vi.fn(() => ({
                select: vi.fn().mockResolvedValue({ data: { id: 1 }, error: null })
            }))
        })),
    },
}));

describe('useAuth Hook', () => {
    beforeEach(() => {
        vi.clearAllMocks();
    });

    it('should initialize with session if exists', async () => {
        const mockSession = { user: { id: '123' }, access_token: 'token' };
        supabase.auth.getSession.mockResolvedValue({ data: { session: mockSession } });
        supabase.auth.onAuthStateChange.mockReturnValue({ data: { subscription: { unsubscribe: vi.fn() } } });

        const { result } = renderHook(() => useAuth());

        // Initially loading
        expect(result.current.loading).toBe(true);

        // Wait for useEffect
        await waitFor(() => {
            expect(result.current.loading).toBe(false);
        });

        expect(result.current.user).toEqual(mockSession.user);
        expect(result.current.session).toEqual(mockSession);
    });

    it('should handle signIn', async () => {
        const mockUser = { id: '123', email: 'test@example.com' };
        supabase.auth.getSession.mockResolvedValue({ data: { session: null } });
        supabase.auth.onAuthStateChange.mockReturnValue({ data: { subscription: { unsubscribe: vi.fn() } } });
        supabase.auth.signInWithPassword.mockResolvedValue({ data: { user: mockUser }, error: null });

        const { result } = renderHook(() => useAuth());

        await waitFor(() => expect(result.current.loading).toBe(false));

        await act(async () => {
            await result.current.signIn('test@example.com', 'password');
        });

        expect(supabase.auth.signInWithPassword).toHaveBeenCalledWith({
            email: 'test@example.com',
            password: 'password',
        });
    });

    it('should handle signOut', async () => {
        supabase.auth.getSession.mockResolvedValue({ data: { session: null } });
        supabase.auth.onAuthStateChange.mockReturnValue({ data: { subscription: { unsubscribe: vi.fn() } } });
        supabase.auth.signOut.mockResolvedValue({ error: null });

        const { result } = renderHook(() => useAuth());
        await waitFor(() => expect(result.current.loading).toBe(false));

        await act(async () => {
            await result.current.signOut();
        });

        expect(supabase.auth.signOut).toHaveBeenCalled();
    });
});

describe('useGovernanceVote Hook', () => {
    beforeEach(() => {
        vi.clearAllMocks();
    });

    it('should update existing record with governance vote', async () => {
        const mockUser = { id: 'user-123' };
        supabase.auth.getUser.mockResolvedValue({ data: { user: mockUser } });

        // Mock "fetch existing" -> returns record
        const maybeSingleMock = vi.fn().mockResolvedValue({ data: { score: 5 }, error: null });

        // Mock "update" -> returns updated record
        const selectMock = vi.fn().mockResolvedValue({ data: { id: 1, action_vote: 'keep' }, error: null });
        const updateMock = vi.fn().mockReturnValue({
            eq: vi.fn().mockReturnValue({
                eq: vi.fn().mockReturnValue({
                    eq: vi.fn().mockReturnValue({
                        select: selectMock
                    })
                })
            })
        });

        // Set up chained mocks
        // 1. First call to .from('user_scores') is for fetch
        // 2. Second call is for update
        supabase.from.mockImplementation((table) => {
            if (table === 'user_scores') {
                return {
                    select: vi.fn().mockReturnValue({
                        eq: vi.fn().mockReturnValue({
                            eq: vi.fn().mockReturnValue({
                                eq: vi.fn().mockReturnValue({
                                    maybeSingle: maybeSingleMock
                                })
                            })
                        })
                    }),
                    update: updateMock,
                    insert: vi.fn() // Should not be called
                };
            }
            return {};
        });

        const { result } = renderHook(() => useGovernanceVote());

        await act(async () => {
            await result.current.submitGovernanceVote('target-1', 1, 'keep', 'notes');
        });

        // Verify Fetch
        expect(maybeSingleMock).toHaveBeenCalled();

        // Verify Update
        expect(updateMock).toHaveBeenCalledWith({
            action_vote: 'keep',
            action_notes: 'notes',
            updated_at: expect.any(String)
        });
    });

    it('should insert new record with default score if none exists', async () => {
        const mockUser = { id: 'user-123' };
        supabase.auth.getUser.mockResolvedValue({ data: { user: mockUser } });

        // Mock "fetch existing" -> returns null
        const maybeSingleMock = vi.fn().mockResolvedValue({ data: null, error: null });

        // Mock "insert" -> returns new record
        const selectMock = vi.fn().mockResolvedValue({ data: { id: 1, score: 0 }, error: null });
        const insertMock = vi.fn().mockReturnValue({ select: selectMock });

        supabase.from.mockImplementation((table) => {
            if (table === 'user_scores') {
                return {
                    select: vi.fn().mockReturnValue({
                        eq: vi.fn().mockReturnValue({
                            eq: vi.fn().mockReturnValue({
                                eq: vi.fn().mockReturnValue({
                                    maybeSingle: maybeSingleMock
                                })
                            })
                        })
                    }),
                    update: vi.fn(), // Should not be called
                    insert: insertMock
                };
            }
            return {};
        });

        const { result } = renderHook(() => useGovernanceVote());

        await act(async () => {
            await result.current.submitGovernanceVote('target-1', 1, 'drop', 'reason');
        });

        // Verify Fetch
        expect(maybeSingleMock).toHaveBeenCalled();

        // Verify Insert with default score
        expect(insertMock).toHaveBeenCalledWith({
            user_id: 'user-123',
            target_id: 'target-1',
            metric_id: 1,
            score: 0,
            score_type: 'slider',
            action_vote: 'drop',
            action_notes: 'reason',
            updated_at: expect.any(String)
        });
    });

    it('should handle race condition (conflict on insert) by retrying with update', async () => {
        const mockUser = { id: 'user-123' };
        supabase.auth.getUser.mockResolvedValue({ data: { user: mockUser } });

        // Mock "fetch existing" -> returns null (simulate no record found initially)
        const maybeSingleMock = vi.fn().mockResolvedValue({ data: null, error: null });

        // Mock "insert" -> returns ERROR 23505
        const insertSelectMock = vi.fn().mockResolvedValue({ data: null, error: { code: '23505', message: 'Duplicate key' } });
        const insertMock = vi.fn().mockReturnValue({ select: insertSelectMock });

        // Mock "retry update" -> returns success
        const retrySelectMock = vi.fn().mockResolvedValue({ data: { id: 1, action_vote: 'retry' }, error: null });
        const updateMock = vi.fn().mockReturnValue({
            eq: vi.fn().mockReturnValue({
                eq: vi.fn().mockReturnValue({
                    eq: vi.fn().mockReturnValue({
                        select: retrySelectMock
                    })
                })
            })
        });

        supabase.from.mockImplementation((table) => {
            if (table === 'user_scores') {
                return {
                    select: vi.fn().mockReturnValue({
                        eq: vi.fn().mockReturnValue({
                            eq: vi.fn().mockReturnValue({
                                eq: vi.fn().mockReturnValue({
                                    maybeSingle: maybeSingleMock
                                })
                            })
                        })
                    }),
                    insert: insertMock,
                    update: updateMock,
                };
            }
            return {};
        });

        const { result } = renderHook(() => useGovernanceVote());

        await act(async () => {
            await result.current.submitGovernanceVote('target-1', 1, 'retry', 'retry notes');
        });

        // Verify Fetch (simulating race start)
        expect(maybeSingleMock).toHaveBeenCalled();

        // Verify Insert was attempted
        expect(insertMock).toHaveBeenCalled();

        // Verify Update was called as fallback
        expect(updateMock).toHaveBeenCalledWith(expect.objectContaining({
            action_vote: 'retry',
            action_notes: 'retry notes'
        }));
    });
});

describe('Discussion Hooks', () => {
    beforeEach(() => {
        vi.clearAllMocks();
    });

    it('should submit comment successfully', async () => {
        const mockUser = { id: 'user-123' };
        supabase.auth.getUser.mockResolvedValue({ data: { user: mockUser } });

        const insertMock = vi.fn().mockReturnValue({ select: vi.fn().mockResolvedValue({ data: { id: 1 }, error: null }) });
        supabase.from.mockReturnValue({ insert: insertMock });

        const { result } = renderHook(() => useSubmitComment());

        await act(async () => {
            await result.current.submitComment(101, 'test comment');
        });

        expect(supabase.from).toHaveBeenCalledWith('metric_discussions');
        expect(insertMock).toHaveBeenCalled();
    });

    it('should vote on comment successfully', async () => {
        const mockUser = { id: 'user-123' };
        supabase.auth.getUser.mockResolvedValue({ data: { user: mockUser } });

        const upsertMock = vi.fn().mockReturnValue({ data: { id: 1 }, error: null });
        supabase.from.mockReturnValue({ upsert: upsertMock });

        const { result } = renderHook(() => useVoteOnComment());

        await act(async () => {
            await result.current.voteOnComment(505, 'upvote');
        });

        expect(supabase.from).toHaveBeenCalledWith('discussion_votes');
        expect(upsertMock).toHaveBeenCalledWith(
            expect.objectContaining({
                discussion_id: 505,
                user_id: 'user-123',
                vote_type: 'upvote'
            }),
            expect.any(Object)
        );
    });

    it('should fetch discussions and merge profiles', async () => {
        const mockDiscussions = [
            { id: 1, user_id: 'u1', comment: 'c1' },
            { id: 2, user_id: 'u2', comment: 'c2' }
        ];
        const mockProfiles = [
            { user_id: 'u1', full_name: 'User One', role: 'user' },
            { user_id: 'u2', full_name: 'User Two', role: 'admin' }
        ];

        const selectDiscussionsMock = vi.fn().mockResolvedValue({ data: mockDiscussions, error: null });
        const selectProfilesMock = vi.fn().mockResolvedValue({ data: mockProfiles, error: null });
        const selectVotesMock = vi.fn().mockResolvedValue({ data: [], error: null });

        supabase.from.mockImplementation((table) => {
            if (table === 'metric_discussions') {
                return {
                    select: vi.fn().mockReturnValue({
                        eq: vi.fn().mockReturnValue({
                            order: selectDiscussionsMock
                        })
                    })
                };
            }
            if (table === 'user_profiles') {
                return {
                    select: vi.fn().mockReturnValue({
                        in: selectProfilesMock
                    })
                };
            }
            if (table === 'discussion_votes') {
                return {
                    select: vi.fn().mockReturnValue({
                        in: selectVotesMock
                    })
                };
            }
            return {};
        });

        const { result } = renderHook(() => useDiscussions(123));

        await waitFor(() => expect(result.current.loading).toBe(false));

        expect(result.current.data).toHaveLength(2);
        // Ensure manual merge worked
        expect(result.current.data[0].user_profiles).toEqual(mockProfiles[0]);
        expect(result.current.data[1].user_profiles).toEqual(mockProfiles[1]);
    });
});

describe('useUserScores Hook', () => {
    beforeEach(() => {
        vi.clearAllMocks();
    });

    it('should query user scores when user is defined', async () => {
        const userId = 'user-1';
        const targetId = 'target-A';
        const mockData = [{ id: 1 }];

        // Setup chain: from -> select -> eq -> eq -> resolved value
        const eqTargetMock = vi.fn().mockResolvedValue({ data: mockData, error: null });
        const eqUserMock = vi.fn().mockReturnValue({ eq: eqTargetMock });
        const selectMock = vi.fn().mockReturnValue({ eq: eqUserMock });

        supabase.from.mockReturnValue({
            select: selectMock
        });

        const { result } = renderHook(() => useUserScores(userId, targetId));

        await waitFor(() => expect(result.current.loading).toBe(false));

        expect(supabase.from).toHaveBeenCalledWith('user_scores');
        expect(selectMock).toHaveBeenCalledWith('*, metrics(*)');
        expect(eqUserMock).toHaveBeenCalledWith('user_id', userId);
        expect(result.current.data).toEqual(mockData);
    });

    it('should NOT query user scores when user is undefined', async () => {
        const userId = undefined;
        const targetId = 'target-A';

        const { result } = renderHook(() => useUserScores(userId, targetId));

        await waitFor(() => expect(result.current.loading).toBe(false));

        expect(supabase.from).not.toHaveBeenCalled();
        expect(result.current.data).toEqual([]);
    });
});
