-- Ultimate Blog Add-ons: Index pack

-- Options
CREATE INDEX IF NOT EXISTS idx_options_autoload ON website_content.options(autoload) WHERE is_deleted = FALSE;

-- Meta tables
CREATE INDEX IF NOT EXISTS idx_post_meta_post_id_key ON website_content.post_meta(post_id, key);
CREATE INDEX IF NOT EXISTS idx_user_meta_user_id_key ON website_content.user_meta(user_id, key);
CREATE INDEX IF NOT EXISTS idx_comment_meta_comment_id_key ON website_content.comment_meta(comment_id, key);
CREATE INDEX IF NOT EXISTS idx_product_meta_product_id_key ON website_content.product_meta(product_id, key);

-- Editorial workflow
CREATE INDEX IF NOT EXISTS idx_editor_locks_locked_by ON website_content.editor_locks(locked_by);
CREATE INDEX IF NOT EXISTS idx_editor_locks_expires_at ON website_content.editor_locks(expires_at);

CREATE INDEX IF NOT EXISTS idx_autosaves_entity_saved_at ON website_content.autosaves(entity_type, entity_id, saved_at DESC);

CREATE INDEX IF NOT EXISTS idx_review_queue_status_created_at ON website_content.review_queue(status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_review_queue_reviewer_id ON website_content.review_queue(reviewer_id);

CREATE INDEX IF NOT EXISTS idx_content_schedule_status_run_at ON website_content.content_schedule(status, run_at);

-- SEO + redirects
CREATE INDEX IF NOT EXISTS idx_slug_history_old_slug ON website_content.slug_history(old_slug);
CREATE INDEX IF NOT EXISTS idx_slug_history_entity ON website_content.slug_history(entity_type, entity_id);

CREATE INDEX IF NOT EXISTS idx_redirects_hits ON website_content.redirects(hits DESC);

CREATE INDEX IF NOT EXISTS idx_sitemap_cache_expires_at ON website_content.sitemap_cache(expires_at);

-- Memberships
CREATE INDEX IF NOT EXISTS idx_plans_status ON website_content.plans(status);
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_status ON website_content.subscriptions(user_id, status);
CREATE INDEX IF NOT EXISTS idx_subscriptions_status_period_end ON website_content.subscriptions(status, current_period_end);

CREATE INDEX IF NOT EXISTS idx_entitlements_plan_id ON website_content.entitlements(plan_id);

-- Newsletters
CREATE INDEX IF NOT EXISTS idx_subscribers_status ON website_content.subscribers(status);
CREATE INDEX IF NOT EXISTS idx_memberships_list_id ON website_content.subscriber_list_memberships(list_id);
CREATE INDEX IF NOT EXISTS idx_email_campaigns_status_scheduled_at ON website_content.email_campaigns(status, scheduled_at);
CREATE INDEX IF NOT EXISTS idx_email_deliveries_campaign_status ON website_content.email_deliveries(campaign_id, status);

-- Engagement
CREATE INDEX IF NOT EXISTS idx_saved_posts_user_created_at ON website_content.saved_posts(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_reactions_entity ON website_content.reactions(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_reactions_user_id ON website_content.reactions(user_id);

CREATE INDEX IF NOT EXISTS idx_notifications_user_unread ON website_content.notifications(user_id) WHERE read_at IS NULL;

-- Search logs
CREATE INDEX IF NOT EXISTS idx_search_logs_created_at ON website_content.search_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_search_logs_user_id ON website_content.search_logs(user_id);

-- Rollup
CREATE INDEX IF NOT EXISTS idx_page_views_daily_day ON website_content.page_views_daily(day DESC);

-- Admin safety
CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON website_content.sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_expires_at ON website_content.sessions(expires_at);

CREATE INDEX IF NOT EXISTS idx_password_resets_user_id ON website_content.password_resets(user_id);
CREATE INDEX IF NOT EXISTS idx_password_resets_expires_at ON website_content.password_resets(expires_at);

CREATE INDEX IF NOT EXISTS idx_audit_logs_actor_created_at ON website_content.audit_logs(actor_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON website_content.audit_logs(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_rate_limits_key_window_start ON website_content.rate_limits(key, window_start DESC);
CREATE INDEX IF NOT EXISTS idx_ip_blocks_expires_at ON website_content.ip_blocks(expires_at);

-- Marketplace plus (optional)
CREATE INDEX IF NOT EXISTS idx_orders_buyer_created_at ON website_content.orders(buyer_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON website_content.order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_coupon_redemptions_buyer_id ON website_content.coupon_redemptions(buyer_id);
