export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  graphql_public: {
    Tables: {
      [_ in never]: never
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      graphql: {
        Args: {
          extensions?: Json
          operationName?: string
          query?: string
          variables?: Json
        }
        Returns: Json
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  public: {
    Tables: {
      activity_log: {
        Row: {
          activity_type: string
          created_at: string
          description: string
          discussion_id: string | null
          id: string
          metadata: Json | null
          metric_id: number | null
          rfc_id: string | null
          target_id: string | null
          user_id: string | null
        }
        Insert: {
          activity_type: string
          created_at?: string
          description: string
          discussion_id?: string | null
          id?: string
          metadata?: Json | null
          metric_id?: number | null
          rfc_id?: string | null
          target_id?: string | null
          user_id?: string | null
        }
        Update: {
          activity_type?: string
          created_at?: string
          description?: string
          discussion_id?: string | null
          id?: string
          metadata?: Json | null
          metric_id?: number | null
          rfc_id?: string | null
          target_id?: string | null
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "activity_log_metric_id_fkey"
            columns: ["metric_id"]
            isOneToOne: false
            referencedRelation: "metrics"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "activity_log_metric_id_fkey"
            columns: ["metric_id"]
            isOneToOne: false
            referencedRelation: "target_score_aggregates"
            referencedColumns: ["metric_id"]
          },
          {
            foreignKeyName: "activity_log_rfc_id_fkey"
            columns: ["rfc_id"]
            isOneToOne: false
            referencedRelation: "rfc_proposals"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "activity_log_target_id_fkey"
            columns: ["target_id"]
            isOneToOne: false
            referencedRelation: "target_score_aggregates"
            referencedColumns: ["target_id"]
          },
          {
            foreignKeyName: "activity_log_target_id_fkey"
            columns: ["target_id"]
            isOneToOne: false
            referencedRelation: "targets"
            referencedColumns: ["id"]
          },
        ]
      }
      approved_targets: {
        Row: {
          case_id: string | null
          claim_date: string
          context: string | null
          created_at: string | null
          description: string
          id: string
          name: string
          origin: string | null
          primary_source: string | null
          slug: string | null
          source_url: string | null
          submission_id: string | null
          updated_at: string | null
          verified: boolean | null
        }
        Insert: {
          case_id?: string | null
          claim_date: string
          context?: string | null
          created_at?: string | null
          description: string
          id: string
          name: string
          origin?: string | null
          primary_source?: string | null
          slug?: string | null
          source_url?: string | null
          submission_id?: string | null
          updated_at?: string | null
          verified?: boolean | null
        }
        Update: {
          case_id?: string | null
          claim_date?: string
          context?: string | null
          created_at?: string | null
          description?: string
          id?: string
          name?: string
          origin?: string | null
          primary_source?: string | null
          slug?: string | null
          source_url?: string | null
          submission_id?: string | null
          updated_at?: string | null
          verified?: boolean | null
        }
        Relationships: [
          {
            foreignKeyName: "approved_targets_submission_id_fkey"
            columns: ["submission_id"]
            isOneToOne: false
            referencedRelation: "target_submissions"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fk_approved_targets_context_types"
            columns: ["context"]
            isOneToOne: false
            referencedRelation: "context_types"
            referencedColumns: ["slug"]
          },
          {
            foreignKeyName: "fk_approved_targets_origin_types"
            columns: ["origin"]
            isOneToOne: false
            referencedRelation: "origin_types"
            referencedColumns: ["slug"]
          },
        ]
      }
      assessment_notes: {
        Row: {
          created_at: string
          id: string
          is_current: boolean | null
          is_public: boolean | null
          metric_id: number
          note_text: string
          note_type: string | null
          target_id: string
          updated_at: string
          user_id: string
          version: number | null
        }
        Insert: {
          created_at?: string
          id?: string
          is_current?: boolean | null
          is_public?: boolean | null
          metric_id: number
          note_text: string
          note_type?: string | null
          target_id: string
          updated_at?: string
          user_id: string
          version?: number | null
        }
        Update: {
          created_at?: string
          id?: string
          is_current?: boolean | null
          is_public?: boolean | null
          metric_id?: number
          note_text?: string
          note_type?: string | null
          target_id?: string
          updated_at?: string
          user_id?: string
          version?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "assessment_notes_metric_id_fkey"
            columns: ["metric_id"]
            isOneToOne: false
            referencedRelation: "metrics"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "assessment_notes_metric_id_fkey"
            columns: ["metric_id"]
            isOneToOne: false
            referencedRelation: "target_score_aggregates"
            referencedColumns: ["metric_id"]
          },
          {
            foreignKeyName: "assessment_notes_target_id_fkey"
            columns: ["target_id"]
            isOneToOne: false
            referencedRelation: "target_score_aggregates"
            referencedColumns: ["target_id"]
          },
          {
            foreignKeyName: "assessment_notes_target_id_fkey"
            columns: ["target_id"]
            isOneToOne: false
            referencedRelation: "targets"
            referencedColumns: ["id"]
          },
        ]
      }
      community_votes: {
        Row: {
          confidence_level: string
          created_at: string
          id: string
          metric_id: number | null
          rationale: string | null
          target_id: string | null
          updated_at: string
          user_id: string | null
          vote_timestamp: string | null
          vote_value: number
        }
        Insert: {
          confidence_level?: string
          created_at?: string
          id?: string
          metric_id?: number | null
          rationale?: string | null
          target_id?: string | null
          updated_at?: string
          user_id?: string | null
          vote_timestamp?: string | null
          vote_value: number
        }
        Update: {
          confidence_level?: string
          created_at?: string
          id?: string
          metric_id?: number | null
          rationale?: string | null
          target_id?: string | null
          updated_at?: string
          user_id?: string | null
          vote_timestamp?: string | null
          vote_value?: number
        }
        Relationships: [
          {
            foreignKeyName: "community_votes_metric_id_fkey"
            columns: ["metric_id"]
            isOneToOne: false
            referencedRelation: "metrics"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "community_votes_metric_id_fkey"
            columns: ["metric_id"]
            isOneToOne: false
            referencedRelation: "target_score_aggregates"
            referencedColumns: ["metric_id"]
          },
          {
            foreignKeyName: "community_votes_target_id_fkey"
            columns: ["target_id"]
            isOneToOne: false
            referencedRelation: "target_score_aggregates"
            referencedColumns: ["target_id"]
          },
          {
            foreignKeyName: "community_votes_target_id_fkey"
            columns: ["target_id"]
            isOneToOne: false
            referencedRelation: "targets"
            referencedColumns: ["id"]
          },
        ]
      }
      context_types: {
        Row: {
          created_at: string
          description: string | null
          is_active: boolean
          label: string
          slug: string
          sort_order: number
          updated_at: string
        }
        Insert: {
          created_at?: string
          description?: string | null
          is_active?: boolean
          label: string
          slug: string
          sort_order?: number
          updated_at?: string
        }
        Update: {
          created_at?: string
          description?: string | null
          is_active?: boolean
          label?: string
          slug?: string
          sort_order?: number
          updated_at?: string
        }
        Relationships: []
      }
      discussion_votes: {
        Row: {
          created_at: string | null
          discussion_id: string | null
          id: string
          user_id: string | null
          vote_type: string | null
        }
        Insert: {
          created_at?: string | null
          discussion_id?: string | null
          id?: string
          user_id?: string | null
          vote_type?: string | null
        }
        Update: {
          created_at?: string | null
          discussion_id?: string | null
          id?: string
          user_id?: string | null
          vote_type?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "discussion_votes_discussion_id_fkey"
            columns: ["discussion_id"]
            isOneToOne: false
            referencedRelation: "metric_discussions"
            referencedColumns: ["id"]
          },
        ]
      }
      metric_discussions: {
        Row: {
          comment: string
          created_at: string | null
          downvotes: number | null
          id: string
          metric_id: number
          parent_id: string | null
          updated_at: string | null
          upvotes: number | null
          user_id: string | null
        }
        Insert: {
          comment: string
          created_at?: string | null
          downvotes?: number | null
          id?: string
          metric_id: number
          parent_id?: string | null
          updated_at?: string | null
          upvotes?: number | null
          user_id?: string | null
        }
        Update: {
          comment?: string
          created_at?: string | null
          downvotes?: number | null
          id?: string
          metric_id?: number
          parent_id?: string | null
          updated_at?: string | null
          upvotes?: number | null
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "metric_discussions_parent_id_fkey"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "metric_discussions"
            referencedColumns: ["id"]
          },
        ]
      }
      metric_proposal_votes: {
        Row: {
          comment: string | null
          created_at: string | null
          id: string
          proposal_id: string
          user_id: string
          vote_type: string
        }
        Insert: {
          comment?: string | null
          created_at?: string | null
          id?: string
          proposal_id: string
          user_id: string
          vote_type: string
        }
        Update: {
          comment?: string | null
          created_at?: string | null
          id?: string
          proposal_id?: string
          user_id?: string
          vote_type?: string
        }
        Relationships: [
          {
            foreignKeyName: "metric_proposal_votes_proposal_id_fkey"
            columns: ["proposal_id"]
            isOneToOne: false
            referencedRelation: "active_metric_proposals"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "metric_proposal_votes_proposal_id_fkey"
            columns: ["proposal_id"]
            isOneToOne: false
            referencedRelation: "new_metric_proposals"
            referencedColumns: ["id"]
          },
        ]
      }
      metric_versions: {
        Row: {
          category: string
          change_reason: string | null
          changed_by: string | null
          created_at: string
          criteria: string
          id: string
          max_val: number | null
          metric_id: number
          min_val: number | null
          name: string
          question: string
          rfc_id: string | null
          version_number: number
        }
        Insert: {
          category: string
          change_reason?: string | null
          changed_by?: string | null
          created_at?: string
          criteria: string
          id?: string
          max_val?: number | null
          metric_id: number
          min_val?: number | null
          name: string
          question: string
          rfc_id?: string | null
          version_number: number
        }
        Update: {
          category?: string
          change_reason?: string | null
          changed_by?: string | null
          created_at?: string
          criteria?: string
          id?: string
          max_val?: number | null
          metric_id?: number
          min_val?: number | null
          name?: string
          question?: string
          rfc_id?: string | null
          version_number?: number
        }
        Relationships: [
          {
            foreignKeyName: "metric_versions_metric_id_fkey"
            columns: ["metric_id"]
            isOneToOne: false
            referencedRelation: "metrics"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "metric_versions_metric_id_fkey"
            columns: ["metric_id"]
            isOneToOne: false
            referencedRelation: "target_score_aggregates"
            referencedColumns: ["metric_id"]
          },
          {
            foreignKeyName: "metric_versions_rfc_id_fkey"
            columns: ["rfc_id"]
            isOneToOne: false
            referencedRelation: "rfc_proposals"
            referencedColumns: ["id"]
          },
        ]
      }
      metrics: {
        Row: {
          category: string
          community_score: number
          created_at: string
          criteria: string
          high_description: string | null
          id: number
          low_description: string | null
          max_val: number | null
          min_val: number | null
          name: string
          question: string
          scoring_criteria: Json | null
          updated_at: string
        }
        Insert: {
          category: string
          community_score: number
          created_at?: string
          criteria: string
          high_description?: string | null
          id?: number
          low_description?: string | null
          max_val?: number | null
          min_val?: number | null
          name: string
          question: string
          scoring_criteria?: Json | null
          updated_at?: string
        }
        Update: {
          category?: string
          community_score?: number
          created_at?: string
          criteria?: string
          high_description?: string | null
          id?: number
          low_description?: string | null
          max_val?: number | null
          min_val?: number | null
          name?: string
          question?: string
          scoring_criteria?: Json | null
          updated_at?: string
        }
        Relationships: []
      }
      new_metric_proposals: {
        Row: {
          category: string | null
          created_at: string | null
          id: string
          implemented_at: string | null
          implemented_metric_id: number | null
          max_criteria: string
          metric_name: string
          metric_question: string
          min_criteria: string
          opposition_count: number | null
          proposed_by: string
          rationale: string
          review_notes: string | null
          reviewed_at: string | null
          reviewed_by: string | null
          rich_entries: string | null
          status: string
          support_count: number | null
          updated_at: string | null
        }
        Insert: {
          category?: string | null
          created_at?: string | null
          id?: string
          implemented_at?: string | null
          implemented_metric_id?: number | null
          max_criteria: string
          metric_name: string
          metric_question: string
          min_criteria: string
          opposition_count?: number | null
          proposed_by: string
          rationale: string
          review_notes?: string | null
          reviewed_at?: string | null
          reviewed_by?: string | null
          rich_entries?: string | null
          status?: string
          support_count?: number | null
          updated_at?: string | null
        }
        Update: {
          category?: string | null
          created_at?: string | null
          id?: string
          implemented_at?: string | null
          implemented_metric_id?: number | null
          max_criteria?: string
          metric_name?: string
          metric_question?: string
          min_criteria?: string
          opposition_count?: number | null
          proposed_by?: string
          rationale?: string
          review_notes?: string | null
          reviewed_at?: string | null
          reviewed_by?: string | null
          rich_entries?: string | null
          status?: string
          support_count?: number | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "new_metric_proposals_implemented_metric_id_fkey"
            columns: ["implemented_metric_id"]
            isOneToOne: false
            referencedRelation: "metrics"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "new_metric_proposals_implemented_metric_id_fkey"
            columns: ["implemented_metric_id"]
            isOneToOne: false
            referencedRelation: "target_score_aggregates"
            referencedColumns: ["metric_id"]
          },
        ]
      }
      origin_types: {
        Row: {
          abbreviation: string
          created_at: string
          description: string | null
          is_active: boolean
          label: string
          slug: string
          sort_order: number
          updated_at: string
        }
        Insert: {
          abbreviation: string
          created_at?: string
          description?: string | null
          is_active?: boolean
          label: string
          slug: string
          sort_order?: number
          updated_at?: string
        }
        Update: {
          abbreviation?: string
          created_at?: string
          description?: string | null
          is_active?: boolean
          label?: string
          slug?: string
          sort_order?: number
          updated_at?: string
        }
        Relationships: []
      }
      protocol_config: {
        Row: {
          config_key: string
          config_value: string
          description: string | null
          id: number
          updated_at: string | null
          updated_by: string | null
        }
        Insert: {
          config_key: string
          config_value: string
          description?: string | null
          id?: number
          updated_at?: string | null
          updated_by?: string | null
        }
        Update: {
          config_key?: string
          config_value?: string
          description?: string | null
          id?: number
          updated_at?: string | null
          updated_by?: string | null
        }
        Relationships: []
      }
      rfc_proposals: {
        Row: {
          created_at: string
          id: string
          metric_id: number | null
          proposal_type: string
          proposed_category: string | null
          proposed_max_criteria: string | null
          proposed_min_criteria: string | null
          proposed_name: string | null
          proposed_question: string | null
          rationale: string
          review_notes: string | null
          reviewed_at: string | null
          reviewed_by: string | null
          rich_entries: string | null
          status: string | null
          updated_at: string
          user_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          metric_id?: number | null
          proposal_type: string
          proposed_category?: string | null
          proposed_max_criteria?: string | null
          proposed_min_criteria?: string | null
          proposed_name?: string | null
          proposed_question?: string | null
          rationale: string
          review_notes?: string | null
          reviewed_at?: string | null
          reviewed_by?: string | null
          rich_entries?: string | null
          status?: string | null
          updated_at?: string
          user_id: string
        }
        Update: {
          created_at?: string
          id?: string
          metric_id?: number | null
          proposal_type?: string
          proposed_category?: string | null
          proposed_max_criteria?: string | null
          proposed_min_criteria?: string | null
          proposed_name?: string | null
          proposed_question?: string | null
          rationale?: string
          review_notes?: string | null
          reviewed_at?: string | null
          reviewed_by?: string | null
          rich_entries?: string | null
          status?: string | null
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "rfc_proposals_metric_id_fkey"
            columns: ["metric_id"]
            isOneToOne: false
            referencedRelation: "metrics"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "rfc_proposals_metric_id_fkey"
            columns: ["metric_id"]
            isOneToOne: false
            referencedRelation: "target_score_aggregates"
            referencedColumns: ["metric_id"]
          },
        ]
      }
      rfc_votes: {
        Row: {
          confidence_level: string | null
          created_at: string | null
          id: string
          notes: string | null
          rfc_id: string | null
          updated_at: string | null
          user_id: string | null
          vote: string
        }
        Insert: {
          confidence_level?: string | null
          created_at?: string | null
          id?: string
          notes?: string | null
          rfc_id?: string | null
          updated_at?: string | null
          user_id?: string | null
          vote: string
        }
        Update: {
          confidence_level?: string | null
          created_at?: string | null
          id?: string
          notes?: string | null
          rfc_id?: string | null
          updated_at?: string | null
          user_id?: string | null
          vote?: string
        }
        Relationships: [
          {
            foreignKeyName: "rfc_votes_rfc_id_fkey"
            columns: ["rfc_id"]
            isOneToOne: false
            referencedRelation: "rfc_proposals"
            referencedColumns: ["id"]
          },
        ]
      }
      saved_searches: {
        Row: {
          created_at: string | null
          filters: Json | null
          id: string
          last_used_at: string | null
          name: string
          search_query: string
          use_count: number | null
          user_id: string
        }
        Insert: {
          created_at?: string | null
          filters?: Json | null
          id?: string
          last_used_at?: string | null
          name: string
          search_query: string
          use_count?: number | null
          user_id: string
        }
        Update: {
          created_at?: string | null
          filters?: Json | null
          id?: string
          last_used_at?: string | null
          name?: string
          search_query?: string
          use_count?: number | null
          user_id?: string
        }
        Relationships: []
      }
      search_history: {
        Row: {
          created_at: string
          id: string
          is_saved: boolean | null
          results_count: number | null
          saved_name: string | null
          search_context: string | null
          search_query: string
          user_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          is_saved?: boolean | null
          results_count?: number | null
          saved_name?: string | null
          search_context?: string | null
          search_query: string
          user_id: string
        }
        Update: {
          created_at?: string
          id?: string
          is_saved?: boolean | null
          results_count?: number | null
          saved_name?: string | null
          search_context?: string | null
          search_query?: string
          user_id?: string
        }
        Relationships: []
      }
      submissions: {
        Row: {
          content: string
          created_at: string
          id: string
          metric_id: number | null
          status: string | null
          submission_type: string
          title: string
          updated_at: string
          user_id: string | null
        }
        Insert: {
          content: string
          created_at?: string
          id?: string
          metric_id?: number | null
          status?: string | null
          submission_type: string
          title: string
          updated_at?: string
          user_id?: string | null
        }
        Update: {
          content?: string
          created_at?: string
          id?: string
          metric_id?: number | null
          status?: string | null
          submission_type?: string
          title?: string
          updated_at?: string
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "submissions_metric_id_fkey"
            columns: ["metric_id"]
            isOneToOne: false
            referencedRelation: "metrics"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "submissions_metric_id_fkey"
            columns: ["metric_id"]
            isOneToOne: false
            referencedRelation: "target_score_aggregates"
            referencedColumns: ["metric_id"]
          },
        ]
      }
      target_submissions: {
        Row: {
          additional_notes: string | null
          case_id: string | null
          claim_date: string
          context: string | null
          created_at: string | null
          description: string
          id: string
          origin: string | null
          primary_source: string | null
          review_notes: string | null
          reviewed_at: string | null
          reviewed_by: string | null
          source_url: string | null
          status: string | null
          submitted_at: string | null
          submitted_by: string | null
          target_name: string
          updated_at: string | null
        }
        Insert: {
          additional_notes?: string | null
          case_id?: string | null
          claim_date: string
          context?: string | null
          created_at?: string | null
          description: string
          id?: string
          origin?: string | null
          primary_source?: string | null
          review_notes?: string | null
          reviewed_at?: string | null
          reviewed_by?: string | null
          source_url?: string | null
          status?: string | null
          submitted_at?: string | null
          submitted_by?: string | null
          target_name: string
          updated_at?: string | null
        }
        Update: {
          additional_notes?: string | null
          case_id?: string | null
          claim_date?: string
          context?: string | null
          created_at?: string | null
          description?: string
          id?: string
          origin?: string | null
          primary_source?: string | null
          review_notes?: string | null
          reviewed_at?: string | null
          reviewed_by?: string | null
          source_url?: string | null
          status?: string | null
          submitted_at?: string | null
          submitted_by?: string | null
          target_name?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "fk_target_submissions_context_types"
            columns: ["context"]
            isOneToOne: false
            referencedRelation: "context_types"
            referencedColumns: ["slug"]
          },
          {
            foreignKeyName: "fk_target_submissions_origin_types"
            columns: ["origin"]
            isOneToOne: false
            referencedRelation: "origin_types"
            referencedColumns: ["slug"]
          },
        ]
      }
      target_tags: {
        Row: {
          created_at: string
          created_by: string | null
          id: string
          tag_name: string
          target_id: string
        }
        Insert: {
          created_at?: string
          created_by?: string | null
          id?: string
          tag_name: string
          target_id: string
        }
        Update: {
          created_at?: string
          created_by?: string | null
          id?: string
          tag_name?: string
          target_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "target_tags_target_id_fkey"
            columns: ["target_id"]
            isOneToOne: false
            referencedRelation: "target_score_aggregates"
            referencedColumns: ["target_id"]
          },
          {
            foreignKeyName: "target_tags_target_id_fkey"
            columns: ["target_id"]
            isOneToOne: false
            referencedRelation: "targets"
            referencedColumns: ["id"]
          },
        ]
      }
      targets: {
        Row: {
          case_id: string
          claim_date: string | null
          context: string
          created_at: string
          description: string | null
          id: string
          name: string
          origin: string
          primary_source: string | null
          slug: string | null
          source_url: string | null
          tags: string[] | null
          updated_at: string
          verified: boolean | null
        }
        Insert: {
          case_id: string
          claim_date?: string | null
          context: string
          created_at?: string
          description?: string | null
          id: string
          name: string
          origin: string
          primary_source?: string | null
          slug?: string | null
          source_url?: string | null
          tags?: string[] | null
          updated_at?: string
          verified?: boolean | null
        }
        Update: {
          case_id?: string
          claim_date?: string | null
          context?: string
          created_at?: string
          description?: string | null
          id?: string
          name?: string
          origin?: string
          primary_source?: string | null
          slug?: string | null
          source_url?: string | null
          tags?: string[] | null
          updated_at?: string
          verified?: boolean | null
        }
        Relationships: [
          {
            foreignKeyName: "fk_targets_context_types"
            columns: ["context"]
            isOneToOne: false
            referencedRelation: "context_types"
            referencedColumns: ["slug"]
          },
          {
            foreignKeyName: "fk_targets_origin_types"
            columns: ["origin"]
            isOneToOne: false
            referencedRelation: "origin_types"
            referencedColumns: ["slug"]
          },
        ]
      }
      user_preferences: {
        Row: {
          created_at: string
          discussion_notifications: boolean | null
          email_notifications: boolean | null
          id: string
          items_per_page: number | null
          last_viewed_tab: string | null
          rfc_notifications: boolean | null
          saved_filters: Json | null
          search_query: string | null
          selected_category_filter: string | null
          show_consensus_overlay: boolean | null
          sidebar_collapsed: boolean | null
          theme: string | null
          updated_at: string
          user_id: string
        }
        Insert: {
          created_at?: string
          discussion_notifications?: boolean | null
          email_notifications?: boolean | null
          id?: string
          items_per_page?: number | null
          last_viewed_tab?: string | null
          rfc_notifications?: boolean | null
          saved_filters?: Json | null
          search_query?: string | null
          selected_category_filter?: string | null
          show_consensus_overlay?: boolean | null
          sidebar_collapsed?: boolean | null
          theme?: string | null
          updated_at?: string
          user_id: string
        }
        Update: {
          created_at?: string
          discussion_notifications?: boolean | null
          email_notifications?: boolean | null
          id?: string
          items_per_page?: number | null
          last_viewed_tab?: string | null
          rfc_notifications?: boolean | null
          saved_filters?: Json | null
          search_query?: string | null
          selected_category_filter?: string | null
          show_consensus_overlay?: boolean | null
          sidebar_collapsed?: boolean | null
          theme?: string | null
          updated_at?: string
          user_id?: string
        }
        Relationships: []
      }
      user_profiles: {
        Row: {
          allow_public_profile: boolean | null
          anonymous: boolean | null
          avatar_url: string | null
          beta_features_enabled: boolean | null
          bio: string | null
          contributor_id: string | null
          created_at: string
          full_name: string | null
          id: string
          is_verified: boolean | null
          last_pseudonym_change: string | null
          location: string | null
          oauth_handle: string | null
          oauth_profile_url: string | null
          oauth_provider: string | null
          oauth_verified: boolean | null
          oauth_verified_at: string | null
          pseudonym: string | null
          role: string
          show_in_leaderboard: boolean | null
          updated_at: string
          user_id: string
          website: string | null
        }
        Insert: {
          allow_public_profile?: boolean | null
          anonymous?: boolean | null
          avatar_url?: string | null
          beta_features_enabled?: boolean | null
          bio?: string | null
          contributor_id?: string | null
          created_at?: string
          full_name?: string | null
          id?: string
          is_verified?: boolean | null
          last_pseudonym_change?: string | null
          location?: string | null
          oauth_handle?: string | null
          oauth_profile_url?: string | null
          oauth_provider?: string | null
          oauth_verified?: boolean | null
          oauth_verified_at?: string | null
          pseudonym?: string | null
          role?: string
          show_in_leaderboard?: boolean | null
          updated_at?: string
          user_id: string
          website?: string | null
        }
        Update: {
          allow_public_profile?: boolean | null
          anonymous?: boolean | null
          avatar_url?: string | null
          beta_features_enabled?: boolean | null
          bio?: string | null
          contributor_id?: string | null
          created_at?: string
          full_name?: string | null
          id?: string
          is_verified?: boolean | null
          last_pseudonym_change?: string | null
          location?: string | null
          oauth_handle?: string | null
          oauth_profile_url?: string | null
          oauth_provider?: string | null
          oauth_verified?: boolean | null
          oauth_verified_at?: string | null
          pseudonym?: string | null
          role?: string
          show_in_leaderboard?: boolean | null
          updated_at?: string
          user_id?: string
          website?: string | null
        }
        Relationships: []
      }
      user_score_history: {
        Row: {
          action_notes: string | null
          action_vote: string | null
          change_type: string
          changed_at: string
          id: string
          metric_id: number | null
          notes: string | null
          score: number | null
          target_id: string | null
          user_id: string | null
          user_score_id: string | null
        }
        Insert: {
          action_notes?: string | null
          action_vote?: string | null
          change_type: string
          changed_at?: string
          id?: string
          metric_id?: number | null
          notes?: string | null
          score?: number | null
          target_id?: string | null
          user_id?: string | null
          user_score_id?: string | null
        }
        Update: {
          action_notes?: string | null
          action_vote?: string | null
          change_type?: string
          changed_at?: string
          id?: string
          metric_id?: number | null
          notes?: string | null
          score?: number | null
          target_id?: string | null
          user_id?: string | null
          user_score_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "user_score_history_metric_id_fkey"
            columns: ["metric_id"]
            isOneToOne: false
            referencedRelation: "metrics"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "user_score_history_metric_id_fkey"
            columns: ["metric_id"]
            isOneToOne: false
            referencedRelation: "target_score_aggregates"
            referencedColumns: ["metric_id"]
          },
          {
            foreignKeyName: "user_score_history_target_id_fkey"
            columns: ["target_id"]
            isOneToOne: false
            referencedRelation: "target_score_aggregates"
            referencedColumns: ["target_id"]
          },
          {
            foreignKeyName: "user_score_history_target_id_fkey"
            columns: ["target_id"]
            isOneToOne: false
            referencedRelation: "targets"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "user_score_history_user_score_id_fkey"
            columns: ["user_score_id"]
            isOneToOne: false
            referencedRelation: "user_scores"
            referencedColumns: ["id"]
          },
        ]
      }
      user_scores: {
        Row: {
          action_notes: string | null
          action_vote: string | null
          confidence_level: string | null
          created_at: string
          id: string
          last_updated_at: string | null
          metric_id: number | null
          notes: string | null
          score: number
          score_type: string | null
          target_id: string | null
          updated_at: string
          user_id: string | null
        }
        Insert: {
          action_notes?: string | null
          action_vote?: string | null
          confidence_level?: string | null
          created_at?: string
          id?: string
          last_updated_at?: string | null
          metric_id?: number | null
          notes?: string | null
          score: number
          score_type?: string | null
          target_id?: string | null
          updated_at?: string
          user_id?: string | null
        }
        Update: {
          action_notes?: string | null
          action_vote?: string | null
          confidence_level?: string | null
          created_at?: string
          id?: string
          last_updated_at?: string | null
          metric_id?: number | null
          notes?: string | null
          score?: number
          score_type?: string | null
          target_id?: string | null
          updated_at?: string
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "user_scores_metric_id_fkey"
            columns: ["metric_id"]
            isOneToOne: false
            referencedRelation: "metrics"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "user_scores_metric_id_fkey"
            columns: ["metric_id"]
            isOneToOne: false
            referencedRelation: "target_score_aggregates"
            referencedColumns: ["metric_id"]
          },
          {
            foreignKeyName: "user_scores_target_id_fkey"
            columns: ["target_id"]
            isOneToOne: false
            referencedRelation: "target_score_aggregates"
            referencedColumns: ["target_id"]
          },
          {
            foreignKeyName: "user_scores_target_id_fkey"
            columns: ["target_id"]
            isOneToOne: false
            referencedRelation: "targets"
            referencedColumns: ["id"]
          },
        ]
      }
      user_sessions: {
        Row: {
          actions_count: number | null
          device_type: string | null
          ended_at: string | null
          id: string
          ip_address: unknown
          last_activity_at: string
          page_views: number | null
          session_id: string
          started_at: string
          user_agent: string | null
          user_id: string | null
        }
        Insert: {
          actions_count?: number | null
          device_type?: string | null
          ended_at?: string | null
          id?: string
          ip_address?: unknown
          last_activity_at?: string
          page_views?: number | null
          session_id: string
          started_at?: string
          user_agent?: string | null
          user_id?: string | null
        }
        Update: {
          actions_count?: number | null
          device_type?: string | null
          ended_at?: string | null
          id?: string
          ip_address?: unknown
          last_activity_at?: string
          page_views?: number | null
          session_id?: string
          started_at?: string
          user_agent?: string | null
          user_id?: string | null
        }
        Relationships: []
      }
      vote_rationales: {
        Row: {
          created_at: string | null
          id: string
          metric_id: number
          rationale: string
          target_id: string
          updated_at: string | null
          user_id: string
          vote_id: string
        }
        Insert: {
          created_at?: string | null
          id?: string
          metric_id: number
          rationale: string
          target_id: string
          updated_at?: string | null
          user_id: string
          vote_id: string
        }
        Update: {
          created_at?: string | null
          id?: string
          metric_id?: number
          rationale?: string
          target_id?: string
          updated_at?: string | null
          user_id?: string
          vote_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "vote_rationales_metric_id_fkey"
            columns: ["metric_id"]
            isOneToOne: false
            referencedRelation: "metrics"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "vote_rationales_metric_id_fkey"
            columns: ["metric_id"]
            isOneToOne: false
            referencedRelation: "target_score_aggregates"
            referencedColumns: ["metric_id"]
          },
          {
            foreignKeyName: "vote_rationales_target_id_fkey"
            columns: ["target_id"]
            isOneToOne: false
            referencedRelation: "target_score_aggregates"
            referencedColumns: ["target_id"]
          },
          {
            foreignKeyName: "vote_rationales_target_id_fkey"
            columns: ["target_id"]
            isOneToOne: false
            referencedRelation: "targets"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "vote_rationales_vote_id_fkey"
            columns: ["vote_id"]
            isOneToOne: true
            referencedRelation: "community_votes"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      active_metric_proposals: {
        Row: {
          category: string | null
          created_at: string | null
          id: string | null
          implemented_at: string | null
          implemented_metric_id: number | null
          max_criteria: string | null
          metric_name: string | null
          metric_question: string | null
          min_criteria: string | null
          net_support: number | null
          opposition_count: number | null
          proposed_by: string | null
          proposer_name: string | null
          rationale: string | null
          review_notes: string | null
          reviewed_at: string | null
          reviewed_by: string | null
          rich_entries: string | null
          status: string | null
          support_count: number | null
          total_opposition: number | null
          total_support: number | null
          updated_at: string | null
        }
        Relationships: [
          {
            foreignKeyName: "new_metric_proposals_implemented_metric_id_fkey"
            columns: ["implemented_metric_id"]
            isOneToOne: false
            referencedRelation: "metrics"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "new_metric_proposals_implemented_metric_id_fkey"
            columns: ["implemented_metric_id"]
            isOneToOne: false
            referencedRelation: "target_score_aggregates"
            referencedColumns: ["metric_id"]
          },
        ]
      }
      current_assessment_notes: {
        Row: {
          created_at: string | null
          id: string | null
          is_current: boolean | null
          is_public: boolean | null
          metric_id: number | null
          note_text: string | null
          note_type: string | null
          target_id: string | null
          updated_at: string | null
          user_id: string | null
          version: number | null
        }
        Insert: {
          created_at?: string | null
          id?: string | null
          is_current?: boolean | null
          is_public?: boolean | null
          metric_id?: number | null
          note_text?: string | null
          note_type?: string | null
          target_id?: string | null
          updated_at?: string | null
          user_id?: string | null
          version?: number | null
        }
        Update: {
          created_at?: string | null
          id?: string | null
          is_current?: boolean | null
          is_public?: boolean | null
          metric_id?: number | null
          note_text?: string | null
          note_type?: string | null
          target_id?: string | null
          updated_at?: string | null
          user_id?: string | null
          version?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "assessment_notes_metric_id_fkey"
            columns: ["metric_id"]
            isOneToOne: false
            referencedRelation: "metrics"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "assessment_notes_metric_id_fkey"
            columns: ["metric_id"]
            isOneToOne: false
            referencedRelation: "target_score_aggregates"
            referencedColumns: ["metric_id"]
          },
          {
            foreignKeyName: "assessment_notes_target_id_fkey"
            columns: ["target_id"]
            isOneToOne: false
            referencedRelation: "target_score_aggregates"
            referencedColumns: ["target_id"]
          },
          {
            foreignKeyName: "assessment_notes_target_id_fkey"
            columns: ["target_id"]
            isOneToOne: false
            referencedRelation: "targets"
            referencedColumns: ["id"]
          },
        ]
      }
      public_profiles: {
        Row: {
          anonymous: boolean | null
          avatar_url: string | null
          bio: string | null
          contributor_id: string | null
          created_at: string | null
          display_name: string | null
          oauth_verified: boolean | null
          user_id: string | null
          verified_provider: string | null
          verified_url: string | null
        }
        Insert: {
          anonymous?: boolean | null
          avatar_url?: never
          bio?: never
          contributor_id?: string | null
          created_at?: string | null
          display_name?: never
          oauth_verified?: boolean | null
          user_id?: string | null
          verified_provider?: never
          verified_url?: never
        }
        Update: {
          anonymous?: boolean | null
          avatar_url?: never
          bio?: never
          contributor_id?: string | null
          created_at?: string | null
          display_name?: never
          oauth_verified?: boolean | null
          user_id?: string | null
          verified_provider?: never
          verified_url?: never
        }
        Relationships: []
      }
      target_score_aggregates: {
        Row: {
          average_score: number | null
          consensus_action: string | null
          drop_votes: number | null
          keep_votes: number | null
          metric_id: number | null
          metric_name: string | null
          modify_votes: number | null
          most_common_score: number | null
          target_id: string | null
          target_name: string | null
          total_governance_votes: number | null
          total_votes: number | null
        }
        Relationships: []
      }
    }
    Functions: {
      approve_target_submission: {
        Args: { submission_id_param: string; target_id_param: string }
        Returns: undefined
      }
      check_pseudonym_available: {
        Args: { p_pseudonym: string }
        Returns: boolean
      }
      demote_admin_to_user: { Args: { target_user_id: string }; Returns: Json }
      demote_contributor_to_user: {
        Args: { target_user_id: string }
        Returns: Json
      }
      disable_beta_features_non_contributors: { Args: never; Returns: Json }
      enable_beta_features_all: { Args: never; Returns: Json }
      generate_case_id: {
        Args: { context_param: string; origin_param: string }
        Returns: string
      }
      generate_contributor_id: { Args: never; Returns: string }
      generate_default_pseudonym: { Args: never; Returns: string }
      generate_target_slug: {
        Args: { p_case_id: string; p_target_name: string }
        Returns: string
      }
      get_admin_user_list: {
        Args: never
        Returns: {
          bio: string
          contributor_id: string
          created_at: string
          email: string
          full_name: string
          id: string
          is_verified: boolean
          location: string
          pseudonym: string
          role: string
          website: string
        }[]
      }
      get_assessment_notes: {
        Args: { p_metric_id?: number; p_target_id: string }
        Returns: {
          created_at: string
          id: string
          is_public: boolean
          note_text: string
          note_type: string
          user_name: string
        }[]
      }
      get_governance_summary: {
        Args: { metric_id_param: number; target_id_param: string }
        Returns: {
          action_vote: string
          percentage: number
          vote_count: number
        }[]
      }
      get_metric_discussion_count: {
        Args: { metric_id_param: number }
        Returns: number
      }
      get_saved_searches: {
        Args: never
        Returns: {
          created_at: string
          id: string
          saved_name: string
          search_context: string
          search_query: string
        }[]
      }
      get_system_activity_feed: {
        Args: {
          p_activity_types?: string[]
          p_limit?: number
          p_offset?: number
        }
        Returns: {
          activity_type: string
          created_at: string
          description: string
          id: string
          metadata: Json
          metric_name: string
          target_name: string
          user_name: string
        }[]
      }
      get_user_activity_feed: {
        Args: { p_limit?: number; p_offset?: number }
        Returns: {
          activity_type: string
          created_at: string
          description: string
          id: string
          metadata: Json
          metric_name: string
          target_name: string
        }[]
      }
      get_user_preferences: { Args: never; Returns: Json }
      get_user_role: { Args: never; Returns: string }
      get_user_votes_for_target: {
        Args: { p_target_id: string }
        Returns: {
          confidence_level: string
          metric_id: number
          metric_name: string
          rationale: string
          vote_value: number
          voted_at: string
        }[]
      }
      has_beta_access: { Args: never; Returns: boolean }
      implement_rfc: { Args: { p_rfc_id: string }; Returns: Json }
      is_admin: { Args: never; Returns: boolean }
      is_contributor: { Args: never; Returns: boolean }
      parse_case_id_from_slug: { Args: { p_slug: string }; Returns: string }
      promote_user_to_admin: { Args: { target_user_id: string }; Returns: Json }
      promote_user_to_contributor: {
        Args: { target_user_id: string }
        Returns: Json
      }
      review_rfc_proposal: {
        Args: { p_review_notes?: string; p_rfc_id: string; p_status: string }
        Returns: Json
      }
      revoke_target_submission: {
        Args: { review_notes_param?: string; submission_id_param: string }
        Returns: undefined
      }
      save_search: {
        Args: {
          p_saved_name: string
          p_search_context: string
          p_search_query: string
        }
        Returns: Json
      }
      submit_assessment_note: {
        Args: {
          p_is_public?: boolean
          p_metric_id: number
          p_note_text: string
          p_note_type?: string
          p_target_id: string
        }
        Returns: Json
      }
      submit_rfc_proposal: {
        Args: {
          p_metric_id: number
          p_proposal_type: string
          p_proposed_category?: string
          p_proposed_max_criteria?: string
          p_proposed_min_criteria?: string
          p_proposed_name?: string
          p_proposed_question?: string
          p_rationale?: string
          p_rich_entries?: string
        }
        Returns: Json
      }
      track_session_activity: {
        Args: { p_page_view?: boolean; p_session_id: string }
        Returns: Json
      }
      unlink_oauth_handle: { Args: never; Returns: Json }
      update_protocol_version: {
        Args: { new_version: string }
        Returns: undefined
      }
      update_pseudonym: { Args: { p_new_pseudonym: string }; Returns: Json }
      update_saved_search_usage: {
        Args: { search_id: string }
        Returns: undefined
      }
      update_user_preferences: { Args: { p_preferences: Json }; Returns: Json }
      upsert_community_vote: {
        Args: {
          p_confidence_level: string
          p_metric_id: number
          p_rationale?: string
          p_target_id: string
          p_vote_value: number
        }
        Returns: Json
      }
      upsert_rfc_vote:
        | {
            Args: {
              p_confidence_level?: string
              p_notes?: string
              p_rfc_id: string
            }
            Returns: Json
          }
        | {
            Args: {
              p_confidence_level?: string
              p_notes?: string
              p_rfc_id: string
              p_vote: string
            }
            Returns: Json
          }
      verify_oauth_handle: { Args: never; Returns: Json }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  graphql_public: {
    Enums: {},
  },
  public: {
    Enums: {},
  },
} as const

