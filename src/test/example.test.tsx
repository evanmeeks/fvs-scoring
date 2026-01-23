import { render } from "@testing-library/react";
import { describe, it } from "vitest";
import { axe } from "vitest-axe";

// Example component test with accessibility checks
describe("Accessibility Example", () => {
  it("should have no accessibility violations", async () => {
    const { container } = render(
      <button type="button" aria-label="Close dialog">
        ×
      </button>
    );

    // Run axe accessibility checks
    const results = await axe(container);
    expect(results).toHaveNoViolations();
  });

  it("should catch missing label", async () => {
    const { container } = render(
      <input type="text" />
    );

    const results = await axe(container);
    // This will fail - input missing label
    expect(results).toHaveNoViolations();
  });
});
