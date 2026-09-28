import matplotlib.pyplot as plt
import matplotlib.patches as patches

fig, ax = plt.subplots(figsize=(19, 13), dpi=300)
ax.set_xlim(0, 190)
ax.set_ylim(0, 130)
ax.axis('off')

# Background
fig.patch.set_facecolor('#F8FAFC')
ax.set_facecolor('#F8FAFC')

# Header Title
ax.text(95, 124, "ONLINE SHOPPING MANAGEMENT SYSTEM - ERD (3NF)", 
        fontsize=20, fontweight='bold', ha='center', va='center', color='#0F172A', fontfamily='sans-serif')
ax.text(95, 120, "MySQL 8.0+ Database Schema (InnoDB) | 7 Core Entities & Relationships", 
        fontsize=11, ha='center', va='center', color='#64748B', fontfamily='sans-serif')

def draw_table(ax, x, y, w, h, title, columns, header_color='#1E293B'):
    # Card shadow & border
    shadow = patches.FancyBboxPatch((x + 0.6, y - 0.6), w, h, boxstyle="round,pad=0.2", 
                                    edgecolor='none', facecolor='#CBD5E1', alpha=0.5, zorder=2)
    ax.add_patch(shadow)
    
    card = patches.FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.2", 
                                  edgecolor='#CBD5E1', facecolor='#FFFFFF', linewidth=1.2, zorder=3)
    ax.add_patch(card)
    
    # Header box
    header_h = 4.2
    header = patches.Rectangle((x, y + h - header_h), w, header_h, 
                               facecolor=header_color, edgecolor='none', zorder=4)
    ax.add_patch(header)
    
    # Header title
    ax.text(x + w / 2, y + h - header_h / 2, title.upper(), 
            fontsize=10.5, fontweight='bold', ha='center', va='center', color='#FFFFFF', zorder=5)
    
    # Draw columns
    line_y = y + h - header_h - 2.5
    for col in columns:
        prefix = ""
        prefix_color = '#64748B'
        name_color = '#1E293B'
        
        if col.startswith("[PK]"):
            prefix = "PK "
            col_name = col.replace("[PK]", "").strip()
            prefix_color = '#D97706'
            name_color = '#0F172A'
        elif col.startswith("[FK]"):
            prefix = "FK "
            col_name = col.replace("[FK]", "").strip()
            prefix_color = '#0284C7'
            name_color = '#0F172A'
        elif col.startswith("[PFK]"):
            prefix = "PFK "
            col_name = col.replace("[PFK]", "").strip()
            prefix_color = '#7C3AED'
            name_color = '#0F172A'
        else:
            col_name = col.strip()
            
        parts = col_name.split(" : ")
        cname = parts[0]
        ctype = parts[1] if len(parts) > 1 else ""
        
        if prefix:
            ax.text(x + 1.2, line_y, prefix, fontsize=7.5, fontweight='bold', color=prefix_color, zorder=5)
            ax.text(x + 5.2, line_y, cname, fontsize=8, fontweight='medium', color=name_color, zorder=5)
        else:
            ax.text(x + 2.5, line_y, cname, fontsize=8, color=name_color, zorder=5)
            
        ax.text(x + w - 1.5, line_y, ctype, fontsize=7.5, ha='right', color='#64748B', style='italic', zorder=5)
        line_y -= 2.8

# Coordinates & Dimensions
# Row 1: CATEGORY (left), CUSTOMER (right)
# Row 2: PRODUCT (left), ORDERS (right)
# Row 3: INVENTORY (far left), ORDER_ITEM (middle), PAYMENT (far right)

# 1. CATEGORY
draw_table(ax, 15, 82, 38, 22, "category", [
    "[PK] category_id : INT",
    "category_name : VARCHAR(100)",
    "description : TEXT",
    "created_at : TIMESTAMP"
], '#0F766E')

# 2. CUSTOMER
draw_table(ax, 137, 72, 40, 34, "customer", [
    "[PK] customer_id : INT",
    "full_name : VARCHAR(100)",
    "email : VARCHAR(100)",
    "phone : VARCHAR(20)",
    "password_hash : VARCHAR(255)",
    "created_at : TIMESTAMP",
    "status : VARCHAR(20)",
    "deleted_at : TIMESTAMP"
], '#1E3A8A')

# 3. PRODUCT
draw_table(ax, 15, 34, 40, 38, "product", [
    "[PK] product_id : INT",
    "[FK] category_id : INT",
    "product_name : VARCHAR(150)",
    "description : TEXT",
    "price : NUMERIC(12,2)",
    "stock_quantity : INT",
    "status : VARCHAR(20)",
    "created_at : TIMESTAMP",
    "updated_at : TIMESTAMP",
    "deleted_at : TIMESTAMP"
], '#0F766E')

# 4. INVENTORY
draw_table(ax, 15, 3, 38, 22, "inventory", [
    "[PK] inventory_id : INT",
    "[FK] product_id : INT (UQ)",
    "quantity : INT",
    "updated_at : TIMESTAMP"
], '#0369A1')

# 5. ORDERS
draw_table(ax, 137, 24, 40, 32, "orders", [
    "[PK] order_id : INT",
    "[FK] customer_id : INT",
    "order_date : TIMESTAMP",
    "status : VARCHAR(20)",
    "total_amount : NUMERIC(12,2)",
    "shipping_address : TEXT"
], '#1E3A8A')

# 6. PAYMENT
draw_table(ax, 137, -20 if False else 3, 40, 18, "payment", [
    "[PK] payment_id : INT",
    "[FK] order_id : INT (UQ)",
    "payment_method : VARCHAR(50)",
    "payment_status : VARCHAR(20)",
    "amount : NUMERIC(12,2)",
    "paid_at : TIMESTAMP",
    "transaction_code : VARCHAR(100)"
], '#4338CA')

# 7. ORDER_ITEM (Center)
draw_table(ax, 76, 38, 42, 30, "order_item", [
    "[PK] order_item_id : INT",
    "[FK] order_id : INT",
    "[FK] product_id : INT",
    "quantity : INT",
    "unit_price : NUMERIC(12,2)",
    "subtotal : NUMERIC(12,2)"
], '#6D28D9')

# Connectors with annotations
def draw_arrow(ax, p1, p2, label="", rad=0.0, color='#475569'):
    arrow = patches.ConnectionPatch(p1, p2, "data", "data",
                                  arrowstyle="-|>", mutation_scale=15,
                                  connectionstyle=f"arc3,rad={rad}",
                                  color=color, linewidth=2, zorder=1)
    ax.add_patch(arrow)
    if label:
        mx = (p1[0] + p2[0]) / 2
        my = (p1[1] + p2[1]) / 2 + (2 if rad == 0 else 3)
        ax.text(mx, my, label, fontsize=8.5, fontweight='bold', 
                color='#1E293B', ha='center', va='center',
                bbox=dict(boxstyle="round,pad=0.25", fc='#F1F5F9', ec='#CBD5E1', lw=0.8), zorder=6)

# Category -> Product (1:N)
draw_arrow(ax, (34, 82), (34, 72), "1 : N")

# Product -> Inventory (1:1)
draw_arrow(ax, (34, 34), (34, 25), "1 : 1")

# Customer -> Orders (1:N)
draw_arrow(ax, (157, 72), (157, 56), "1 : N")

# Orders -> Payment (1:1)
draw_arrow(ax, (157, 24), (157, 18 + 3), "1 : 1 (wait, payment top is 21)")

# Product -> Order_Item (1:N)
draw_arrow(ax, (55, 53), (76, 53), "1 : N")

# Orders -> Order_Item (1:N)
draw_arrow(ax, (137, 43), (118, 43), "N : 1")

# Legend
legend_box = patches.FancyBboxPatch((68, 5), 58, 14, boxstyle="round,pad=0.3",
                                    facecolor='#FFFFFF', edgecolor='#CBD5E1', linewidth=1)
ax.add_patch(legend_box)
ax.text(97, 16.5, "CHÚ THÍCH (LEGEND)", fontsize=9, fontweight='bold', ha='center', color='#0F172A')
ax.text(72, 12, "PK", fontsize=8, fontweight='bold', color='#D97706')
ax.text(77, 12, ": Primary Key", fontsize=8, color='#334155')
ax.text(97, 12, "FK", fontsize=8, fontweight='bold', color='#0284C7')
ax.text(102, 12, ": Foreign Key", fontsize=8, color='#334155')
ax.text(72, 8, "1 --- N : Quan hệ một - nhiều", fontsize=7.5, color='#334155')
ax.text(102, 8, "1 --- 1 : Quan hệ một - một (Unique FK)", fontsize=7.5, color='#334155')

plt.tight_layout()
plt.savefig('erd/online_shopping_erd.png', dpi=300, bbox_inches='tight')
plt.savefig('erd/online_shopping_erd.pdf', bbox_inches='tight')
print("ERD generated successfully!")
