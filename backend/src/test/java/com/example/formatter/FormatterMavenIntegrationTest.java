package com.example.formatter;

import static org.assertj.core.api.Assertions.assertThat;

import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Path;
import java.nio.file.Paths;

import org.junit.jupiter.api.Test;

/**
 * Proves that {@code ./mvnw formatter:format} correctly formats
 * {@code FormatterShowcaseUnformatted.java} according to
 * {@code Common-Standards-Eclipse-Code-Profile.xml}.
 *
 * <p>Delegates to {@code verify-formatter.sh}, which:
 * <ol>
 *   <li>Copies the unformatted source into a throw-away temp Maven project.</li>
 *   <li>Runs {@code ./mvnw formatter:format} — asserts the file changed.</li>
 *   <li>Runs {@code ./mvnw formatter:format} again — asserts no further change
 *       (idempotent output conforms to the profile).</li>
 * </ol>
 *
 * <p>The original {@code FormatterShowcaseUnformatted.java} is never modified.
 */
class FormatterMavenIntegrationTest
{

  @Test
  void mvnFormatterFormat_convertsViolationsToConformingOutput() throws Exception
  {
    Path script = Paths.get("src/test/resources/verify-formatter.sh").toAbsolutePath();

    assertThat(script).as("verify-formatter.sh must exist").isRegularFile();

    ProcessBuilder pb = new ProcessBuilder("bash", script.toString());
    pb.directory(Paths.get("").toAbsolutePath().toFile());
    pb.redirectErrorStream(true);

    Process process = pb.start();

    String output;
    try (InputStream in = process.getInputStream())
    {
      output = new String(in.readAllBytes(), StandardCharsets.UTF_8);
    }

    int exitCode = process.waitFor();

    assertThat(exitCode)
      .as("verify-formatter.sh failed (exit %d).\n\nScript output:\n%s", exitCode, output)
      .isEqualTo(0);
  }
}
