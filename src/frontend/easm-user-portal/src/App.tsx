import { BrowserRouter, useRoutes } from "react-router-dom";
import { Provider } from "react-redux";
import { ThemeProvider } from "@mui/material/styles";
import CssBaseline from "@mui/material/CssBaseline";
import DashboardLayout from "./components/DashboardLayout";
import routes from "./routes";
import theme from "./theme";
import { store } from "./store";

// Routes wrapper component
const AppRoutes = () => {
  const routing = useRoutes(routes);
  return routing;
};

function App() {
  return (
    <Provider store={store}>
      <ThemeProvider theme={theme}>
        <CssBaseline />
        <BrowserRouter>
          <DashboardLayout>
            <AppRoutes />
          </DashboardLayout>
        </BrowserRouter>
      </ThemeProvider>
    </Provider>
  );
}

export default App;
