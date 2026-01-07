import { StrictMode } from "react";
import React from "react";
import ReactDOM from "react-dom";
import { createRoot } from "react-dom/client";
import { RouterProvider, createRouter } from "@tanstack/react-router";
import ErrorBoundary from "./components/ErrorBoundary";
import "./main.css";

// Axe accessibility testing in development
if (import.meta.env.DEV) {
  import("@axe-core/react").then((axe) => {
    axe.default(React, ReactDOM, 1000);
  });
}

// Generated route tree
import { routeTree } from "./routeTree.gen";

const router = createRouter({ routeTree });

const rootElement = document.getElementById("root");
if (!rootElement) {
  throw new Error("Root element #root not found");
}

createRoot(rootElement).render(
  <StrictMode>
    <ErrorBoundary>
      <RouterProvider router={router} />
    </ErrorBoundary>
  </StrictMode>,
);
