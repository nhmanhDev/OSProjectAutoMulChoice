import { createBrowserRouter } from "react-router";
import Layout from "./components/Layout";
import Home from "./pages/Home";
import GradingTool from "./pages/GradingTool";
import Results from "./pages/Results";
import History from "./pages/History";
import About from "./pages/About";

// Get base path from Vite (BASE_URL is set by Vite based on base config)
const basePath = import.meta.env.BASE_URL;

export const router = createBrowserRouter([
  {
    path: "/",
    Component: Layout,
    children: [
      { index: true, Component: Home },
      { path: "cham-diem", Component: GradingTool },
      { path: "ket-qua", Component: Results },
      { path: "lich-su", Component: History },
      { path: "gioi-thieu", Component: About },
    ],
  },
], {
  basename: basePath === '/' ? undefined : basePath,
});
