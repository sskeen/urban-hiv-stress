# plot_efa_network.py
"""
Publication-quality Exploratory Factor Analysis (EFA) network diagram.
Generates a bipartite network visualization with factor nodes and observed variables.
"""

import numpy as np
import networkx as nx
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from pathlib import Path


# Placeholder factor loadings
FACTOR_LOADINGS = {
    "Factor 1": {
        "ULSS 8: Transportation": 0.81,
        "ULSS 12: Using public services*": 0.73,
        "ULSS 6: Your physical health": 0.73,
        "ULSS 5: Housing, your living situation": 0.71,
        "ULSS 7: Your neighborhood environment": 0.63,
    },
    "Factor 2": {
        "ULSS 14: Gang activity": 0.89,
        "ULSS 15: Experiences involving \nracism or discrimination": 0.88,
        "ULSS 13: Crime and violence": 0.83,
        "ULSS 20: Relations with racial \ngroups not our own": 0.68,
        "ULSS 21: Relations with police*": 0.61,
    },
}

# Placeholder factor labels
FACTOR_LABELS = {
    "Factor 1": "Hyperlocal everyday stressors",
    "Factor 2": "Strife and disorder stressors",
}

# Visual styling
FACTOR_COLORS = {
    "Factor 1": "#AABBCC",  # Placeholder color
    "Factor 2": "#CCBBAA",  # Placeholder color
}
VARIABLE_COLOR = "#5A6D7A"
EDGE_COLOR = "#5A6D7A"
FACTOR_SIZE = 2500
VARIABLE_BOX_WIDTH = 0.13
VARIABLE_BOX_HEIGHT = 0.06
ARC_RADIUS = 0.42
MIN_EDGE_WIDTH = 1.0
MAX_EDGE_WIDTH = 6.0


def build_graph(factor_loadings: dict) -> nx.Graph:
    """Construct a NetworkX graph from factor loadings."""
    G = nx.Graph()

    for factor, variables in factor_loadings.items():
        G.add_node(factor, node_type="factor")
        for var, loading in variables.items():
            G.add_node(var, node_type="variable")
            G.add_edge(factor, var, loading=loading)

    return G


def compute_layout(factor_loadings: dict) -> dict:
    """
    Compute custom positions: factors at center, variables in arcs.
    """
    pos = {}
    factors = list(factor_loadings.keys())

    # Position factors
    pos[factors[0]] = (-0.4, 0.0)
    pos[factors[1]] = (0.4, 0.0)

    # Position variables in semi-circular arcs around each factor
    for i, (factor, variables) in enumerate(factor_loadings.items()):
        fx, fy = pos[factor]
        var_names = list(variables.keys())
        n_vars = len(var_names)

        # Arc parameters: spread variables from -90° to +90° (left or right side)
        if i == 0:  # Factor 1 on left, variables fan to the left
            angles = np.linspace(np.pi / 2, -np.pi / 2, n_vars)
            direction = -1
        else:  # Factor 2 on right, variables fan to the right
            angles = np.linspace(np.pi / 2, -np.pi / 2, n_vars)
            direction = 1

        for j, var in enumerate(var_names):
            angle = angles[j]
            vx = fx + direction * ARC_RADIUS * np.cos(angle)
            vy = fy + ARC_RADIUS * np.sin(angle)
            pos[var] = (vx, vy)

    return pos


def scale_edge_width(loading: float) -> float:
    """Scale factor loading to edge width."""
    return MIN_EDGE_WIDTH + loading * (MAX_EDGE_WIDTH - MIN_EDGE_WIDTH)


def draw_efa_network(G: nx.Graph, pos: dict, output_path: Path) -> None:
    """Render and save the EFA network diagram."""
    # Set up figure with white background
    fig, ax = plt.subplots(figsize=(12, 8), facecolor="white")
    ax.set_facecolor("white")

    # Separate node types
    factor_nodes = [n for n, d in G.nodes(data=True) if d.get("node_type") == "factor"]
    variable_nodes = [n for n, d in G.nodes(data=True) if d.get("node_type") == "variable"]

    # Draw edges with width scaled by loading, and add loading labels
    for u, v, data in G.edges(data=True):
        loading = data.get("loading", 0.5)
        width = scale_edge_width(loading)
        x_coords = [pos[u][0], pos[v][0]]
        y_coords = [pos[u][1], pos[v][1]]
        ax.plot(x_coords, y_coords, color=EDGE_COLOR, linewidth=width,
                solid_capstyle="round", zorder=1)

        # Add loading label at edge midpoint
        mid_x = (x_coords[0] + x_coords[1]) / 2
        mid_y = (y_coords[0] + y_coords[1]) / 2
        ax.text(
            mid_x, mid_y, f"{loading:.2f}",
            fontsize=8,
            fontfamily="Arial",
            ha="center",
            va="center",
            color="#333333",
            bbox=dict(boxstyle="round,pad=0.15", facecolor="white", edgecolor="none", alpha=0.8),
            zorder=2,
        )

    # Draw variable nodes as hollow squares with short name inside
    for var in variable_nodes:
        x, y = pos[var]
        # Draw hollow rectangle centered at (x, y)
        rect = mpatches.FancyBboxPatch(
            (x - VARIABLE_BOX_WIDTH / 2, y - VARIABLE_BOX_HEIGHT / 2),
            VARIABLE_BOX_WIDTH,
            VARIABLE_BOX_HEIGHT,
            boxstyle="square,pad=0",
            facecolor="white",
            edgecolor=VARIABLE_COLOR,
            linewidth=1.5,
            zorder=3,
        )
        ax.add_patch(rect)
        # Extract short name (before colon) for inside the box
        short_name = var.split(":")[0].strip() if ":" in var else var
        ax.text(
            x, y, short_name,
            fontsize=8,
            fontfamily="Arial",
            fontweight="bold",
            ha="center",
            va="center",
            color="#333333",
            zorder=4,
        )

    # Draw factor nodes (each with its own color)
    for factor in factor_nodes:
        nx.draw_networkx_nodes(
            G, pos,
            nodelist=[factor],
            node_color=FACTOR_COLORS.get(factor, "#4878A8"),
            node_size=FACTOR_SIZE,
            edgecolors="white",
            linewidths=2,
            ax=ax,
        )

    # Draw labels
    # Factor labels (bold, larger) inside nodes
    factor_labels = {n: n for n in factor_nodes}
    nx.draw_networkx_labels(
        G, pos,
        labels=factor_labels,
        font_size=12,
        font_family="Arial",
        font_weight="bold",
        font_color="white",
        ax=ax,
    )

    # Factor descriptive labels (positioned to avoid collisions)
    for factor in factor_nodes:
        x, y = pos[factor]
        label = FACTOR_LABELS.get(factor, "")
        # Factor 1: label to the right and above
        # Factor 2: label to the left and below
        if factor == "Factor 1":
            x_offset, y_offset = 0.06, 0.08
            ha, va = "left", "bottom"
        else:
            x_offset, y_offset = -0.06, -0.08
            ha, va = "right", "top"
        ax.text(
            x + x_offset, y + y_offset, label,
            fontsize=10,
            fontfamily="Arial",
            fontstyle="italic",
            ha=ha,
            va=va,
            color="#333333",
        )

    # Variable labels (positioned outside nodes, showing description only)
    for var in variable_nodes:
        x, y = pos[var]
        # Extract label (after colon) for outside the box
        label = var.split(":", 1)[1].strip() if ":" in var else var
        # Offset label away from center
        if x < 0:
            ha = "right"
            x_offset = -0.08
        else:
            ha = "left"
            x_offset = 0.08

        ax.text(
            x + x_offset, y, label,
            fontsize=9,
            fontfamily="Arial",
            ha=ha,
            va="center",
            color="#333333",
        )

    # Clean up axes
    ax.set_xlim(-1.2, 1.2)
    ax.set_ylim(-0.7, 0.7)
    ax.axis("off")
    ax.set_aspect("equal")

    # Add footnote
    fig.text(
        0.5, 0.22, #0.5, 0.02,
        "*Exceeds 0.60 factor loading threshold only in $n$ = 274 geolinkable subsample geographically restricted to Orleans Parish (see Supplement I).",
        fontsize=8,
        fontfamily="Arial",
        ha="center",
        va="bottom",
        color="#666666",
    )

    # Save figure
    fig.savefig(output_path, dpi=300, bbox_inches="tight", facecolor="white")
    plt.close(fig)
    print(f"Saved: {output_path}")


def main():
    """Generate and save the EFA network diagram."""
    # Build graph
    G = build_graph(FACTOR_LOADINGS)

    # Compute layout
    pos = compute_layout(FACTOR_LOADINGS)

    # Output path
    script_dir = Path(__file__).parent
    output_dir = script_dir.parent / "figures"
    output_dir.mkdir(exist_ok=True)
    output_path = output_dir / "efa_network.png"

    # Draw and save
    draw_efa_network(G, pos, output_path)


if __name__ == "__main__":
    main()
