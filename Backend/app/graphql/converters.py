"""
Converter helpers: SQLAlchemy ORM objects → Strawberry GraphQL types.
"""

from __future__ import annotations

from app.graphql.types import (
    AuthPayload,
    Block as GqlBlock,
    Category as GqlCategory,
    Comment as GqlComment,
    License as GqlLicense,
    MediaAsset as GqlMediaAsset,
    NavItem as GqlNavItem,
    NavMenu as GqlNavMenu,
    Page as GqlPage,
    Permission as GqlPermission,
    Post as GqlPost,
    Product as GqlProduct,
    Purchase as GqlPurchase,
    Role as GqlRole,
    SEO as GqlSEO,
    Tag as GqlTag,
    Template as GqlTemplate,
    User as GqlUser,
)
from app.models import website_content as orm


def orm_permission_to_gql(p: orm.Permission) -> GqlPermission:
    return GqlPermission(
        id=p.id,
        key=p.key,
        name=p.name,
        description=p.description,
        created_at=p.created_at,
        updated_at=p.updated_at,
    )


def orm_role_to_gql(r: orm.Role) -> GqlRole:
    permissions = [
        orm_permission_to_gql(rp.permission)
        for rp in (r.role_permissions or [])
        if rp.permission
    ]
    return GqlRole(
        id=r.id,
        key=r.key,
        name=r.name,
        description=r.description,
        permissions=permissions,
        created_at=r.created_at,
        updated_at=r.updated_at,
    )


def orm_user_to_gql(u: orm.User) -> GqlUser:
    roles = [
        orm_role_to_gql(ur.role)
        for ur in (u.user_roles or [])
        if ur.role
    ]
    return GqlUser(
        id=u.id,
        email=u.email,
        username=u.username,
        display_name=u.display_name,
        avatar_url=u.avatar_url,
        is_active=u.is_active,
        is_verified=u.is_verified,
        roles=roles,
        created_at=u.created_at,
        updated_at=u.updated_at,
    )


def orm_seo_to_gql(s: orm.SEO) -> GqlSEO:
    return GqlSEO(
        id=s.id,
        title=s.title,
        description=s.description,
        canonical_url=s.canonical_url,
        og_title=s.og_title,
        og_description=s.og_description,
        og_image_url=s.og_image_url,
        twitter_card=s.twitter_card,
        noindex=s.noindex,
        nofollow=s.nofollow,
        created_at=s.created_at,
        updated_at=s.updated_at,
    )


def orm_tag_to_gql(t: orm.Tag) -> GqlTag:
    return GqlTag(
        id=t.id,
        slug=t.slug,
        name=t.name,
        created_at=t.created_at,
        updated_at=t.updated_at,
    )


def orm_category_to_gql(c: orm.Category) -> GqlCategory:
    return GqlCategory(
        id=c.id,
        slug=c.slug,
        name=c.name,
        parent_id=c.parent_id,
        children=[],  # avoid deep recursion in list queries
        created_at=c.created_at,
        updated_at=c.updated_at,
    )


def orm_comment_to_gql(c: orm.Comment) -> GqlComment:
    return GqlComment(
        id=c.id,
        post_id=c.post_id,
        author=orm_user_to_gql(c.author) if getattr(c, "author", None) else None,
        body=c.body,
        status=c.status,
        is_deleted=c.is_deleted,
        created_at=c.created_at,
        updated_at=c.updated_at,
    )


def orm_post_to_gql(p: orm.Post) -> GqlPost:
    tags = [orm_tag_to_gql(pt.tag) for pt in (p.post_tags or []) if pt.tag]
    categories = [orm_category_to_gql(pc.category) for pc in (p.post_categories or []) if pc.category]
    comments = [orm_comment_to_gql(c) for c in (p.comments or []) if not c.is_deleted]
    return GqlPost(
        id=p.id,
        author=orm_user_to_gql(p.author),
        seo=orm_seo_to_gql(p.seo) if p.seo else None,
        slug=p.slug,
        title=p.title,
        excerpt=p.excerpt,
        featured_image_url=p.featured_image_url,
        status=p.status,
        published_at=p.published_at,
        archived_at=p.archived_at,
        content_jsonb=p.content_jsonb,
        tags=tags,
        categories=categories,
        comments=comments,
        is_deleted=p.is_deleted,
        created_at=p.created_at,
        updated_at=p.updated_at,
    )


def orm_page_to_gql(p: orm.Page) -> GqlPage:
    return GqlPage(
        id=p.id,
        author=orm_user_to_gql(p.author),
        seo=orm_seo_to_gql(p.seo) if p.seo else None,
        slug=p.slug,
        title=p.title,
        status=p.status,
        published_at=p.published_at,
        archived_at=p.archived_at,
        content_jsonb=p.content_jsonb,
        is_deleted=p.is_deleted,
        created_at=p.created_at,
        updated_at=p.updated_at,
    )


def orm_template_to_gql(t: orm.Template) -> GqlTemplate:
    return GqlTemplate(
        id=t.id,
        author=orm_user_to_gql(t.author),
        seo=orm_seo_to_gql(t.seo) if t.seo else None,
        slug=t.slug,
        name=t.name,
        description=t.description,
        status=t.status,
        content_jsonb=t.content_jsonb,
        created_at=t.created_at,
        updated_at=t.updated_at,
    )


def orm_product_to_gql(p: orm.Product) -> GqlProduct:
    return GqlProduct(
        id=p.id,
        slug=p.slug,
        name=p.name,
        description=p.description,
        product_type=p.product_type,
        price_cents=p.price_cents,
        currency=p.currency,
        status=p.status,
        created_at=p.created_at,
        updated_at=p.updated_at,
    )


def orm_license_to_gql(l: orm.License) -> GqlLicense:
    return GqlLicense(
        id=l.id,
        product_id=l.product_id,
        license_key=l.license_key,
        max_activations=l.max_activations,
        expires_at=l.expires_at,
        created_at=l.created_at,
        updated_at=l.updated_at,
    )


def orm_purchase_to_gql(p: orm.Purchase) -> GqlPurchase:
    return GqlPurchase(
        id=p.id,
        buyer=orm_user_to_gql(p.buyer) if getattr(p, "buyer", None) else None,
        product_id=p.product_id,
        license=orm_license_to_gql(p.license) if getattr(p, "license", None) else None,
        amount_cents=p.amount_cents,
        currency=p.currency,
        provider=p.provider,
        provider_ref=p.provider_ref,
        status=p.status,
        created_at=p.created_at,
        updated_at=p.updated_at,
    )


def orm_media_to_gql(m: orm.MediaAsset) -> GqlMediaAsset:
    return GqlMediaAsset(
        id=m.id,
        uploader=orm_user_to_gql(m.uploader) if getattr(m, "uploader", None) else None,
        file_name=m.file_name,
        content_type=m.content_type,
        byte_size=m.byte_size,
        storage_provider=m.storage_provider,
        storage_bucket=m.storage_bucket,
        storage_key=m.storage_key,
        public_url=m.public_url,
        checksum_sha256=m.checksum_sha256,
        created_at=m.created_at,
        updated_at=m.updated_at,
    )


def orm_nav_item_to_gql(item: orm.NavItem) -> GqlNavItem:
    children = [orm_nav_item_to_gql(c) for c in (item.children or [])]
    return GqlNavItem(
        id=item.id,
        menu_id=item.menu_id,
        parent_id=item.parent_id,
        sort_order=item.sort_order,
        label=item.label,
        href=item.href,
        page_id=item.page_id,
        children=children,
        created_at=item.created_at,
        updated_at=item.updated_at,
    )


def orm_nav_menu_to_gql(m: orm.NavMenu) -> GqlNavMenu:
    top_level = [
        orm_nav_item_to_gql(item)
        for item in sorted(m.items or [], key=lambda x: x.sort_order)
        if item.parent_id is None
    ]
    return GqlNavMenu(
        id=m.id,
        slug=m.slug,
        name=m.name,
        items=top_level,
        created_at=m.created_at,
        updated_at=m.updated_at,
    )
