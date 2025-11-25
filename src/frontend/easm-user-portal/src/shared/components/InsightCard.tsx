import {
  Card,
  CardContent,
  Typography,
  Box,
  List,
  ListItem,
  ListItemText,
  Chip,
} from "@mui/material";

interface Insight {
  name: string;
  count: string;
}

interface InsightCardProps {
  title: string;
  value: string;
  description: string;
  color: string;
  insights?: Insight[];
  insightsCount?: string;
}

const InsightCard: React.FC<InsightCardProps> = ({
  title,
  value,
  description,
  color,
  insights,
  insightsCount,
}) => {
  return (
    <Card
      sx={{
        width: 320,
        height: "100%",
        display: "flex",
        flexDirection: "column",
        "&:hover": { boxShadow: 3 },
        transition: "box-shadow 0.3s",
      }}
    >
      <CardContent
        sx={{ flex: 1, display: "flex", flexDirection: "column", p: 2, "&:last-child": { pb: 2 } }}
      >
        <Box sx={{ display: "flex", alignItems: "center", mb: 2, gap: 1.5 }}>
          <Box
            sx={{
              width: 60,
              height: 60,
              borderRadius: "50%",
              bgcolor: color,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              flexShrink: 0,
            }}
          >
            <Typography variant="h5" sx={{ fontWeight: 700, color: "white" }}>
              {value}
            </Typography>
          </Box>
          <Box>
            <Typography variant="subtitle1" sx={{ fontWeight: 600, fontSize: "1rem" }}>
              {title}
            </Typography>
            <Typography variant="body2" color="text.secondary" sx={{ fontSize: "0.813rem" }}>
              {description}
            </Typography>
          </Box>
        </Box>

        {insightsCount && (
          <Box sx={{ mb: 1.5, textAlign: "center", py: 0.75, bgcolor: "#f5f5f5", borderRadius: 1 }}>
            <Typography variant="body2" color="text.secondary" sx={{ fontSize: "0.75rem" }}>
              Found from {insightsCount}
            </Typography>
          </Box>
        )}

        {insights && insights.length > 0 && (
          <>
            <Typography
              variant="subtitle2"
              sx={{ mb: 1, mt: 1, fontWeight: 600, fontSize: "0.875rem" }}
            >
              Top observations
            </Typography>
            <List dense disablePadding>
              {insights.map((insight, index) => (
                <ListItem
                  key={index}
                  disablePadding
                  sx={{
                    py: 0.4,
                    "&:hover": { bgcolor: "#f5f5f5" },
                    borderRadius: 1,
                  }}
                >
                  <ListItemText
                    primary={
                      <Box
                        sx={{
                          display: "flex",
                          justifyContent: "space-between",
                          alignItems: "center",
                          gap: 1,
                        }}
                      >
                        <Typography
                          variant="body2"
                          sx={{
                            fontSize: "0.75rem",
                            flex: 1,
                            overflow: "hidden",
                            textOverflow: "ellipsis",
                            whiteSpace: "nowrap",
                          }}
                        >
                          {insight.name}
                        </Typography>
                        <Chip
                          label={insight.count}
                          size="small"
                          sx={{
                            height: 16,
                            fontSize: "0.65rem",
                            minWidth: 24,
                            bgcolor: "#e8e8e8",
                            fontWeight: 600,
                          }}
                        />
                      </Box>
                    }
                  />
                </ListItem>
              ))}
            </List>
          </>
        )}

        <Box sx={{ mt: "auto", pt: 1.5 }}>
          <Typography
            variant="body2"
            sx={{
              color: "#0078d4",
              cursor: "pointer",
              fontSize: "0.813rem",
              "&:hover": { textDecoration: "underline" },
            }}
          >
            All {insightsCount?.split(" ")[0]} insights
          </Typography>
        </Box>
      </CardContent>
    </Card>
  );
};

export default InsightCard;
