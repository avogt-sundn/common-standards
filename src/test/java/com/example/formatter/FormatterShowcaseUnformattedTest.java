package com.example.formatter;

import static org.assertj.core.api.Assertions.assertThat;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.eclipse.jdt.core.ToolFactory;
import org.eclipse.jdt.core.formatter.CodeFormatter;
import org.eclipse.jface.text.Document;
import org.eclipse.text.edits.TextEdit;
import org.junit.jupiter.api.Test;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

/**
 * Proves that FormatterShowcaseUnformatted.java is correctly reformatted when the
 * Eclipse formatter is applied with Common-Standards-Eclipse-Code-Profile.xml — the same
 * profile and engine used by {@code mvn formatter:format}.
 *
 * <p>Two assertions are made:
 * <ol>
 *   <li>The formatter <em>changes</em> the file — i.e. the source really was unformatted.</li>
 *   <li>Applying the formatter a <em>second time</em> produces no further changes — i.e.
 *       the result is correctly and stably formatted (idempotent).</li>
 * </ol>
 */
class FormatterShowcaseUnformattedTest
{

  private static final Path PROFILE_PATH = Paths.get("Common-Standards-Eclipse-Code-Profile.xml");
  private static final Path SOURCE_PATH =
    Paths.get("src/main/java/com/example/formatter/FormatterShowcaseUnformatted.java");

  @Test
  void unformattedSource_whenFormattedWithEclipseProfile_isActuallyChanged() throws Exception
  {
    String original = Files.readString(SOURCE_PATH, StandardCharsets.UTF_8);
    Map<String, String> settings = loadProfileSettings();

    String formattedOnce = applyFormatter(original, settings);

    assertThat(formattedOnce)
      .as("The formatter must modify FormatterShowcaseUnformatted.java — "
        + "if this fails the file was already formatted and the test is no longer meaningful")
      .isNotEqualTo(original);
  }

  @Test
  void unformattedSource_whenFormattedWithEclipseProfile_isIdempotent() throws Exception
  {
    String original = Files.readString(SOURCE_PATH, StandardCharsets.UTF_8);
    Map<String, String> settings = loadProfileSettings();

    String formattedOnce = applyFormatter(original, settings);
    String formattedTwice = applyFormatter(formattedOnce, settings);

    assertThat(formattedTwice)
      .as("Formatting must be idempotent: applying the formatter a second time must not "
        + "change the output, which proves the first pass produced correctly formatted code.\n\n"
        + "First pass result:\n%s", formattedOnce)
      .isEqualTo(formattedOnce);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  private String applyFormatter(String source, Map<String, String> settings) throws Exception
  {
    CodeFormatter formatter = ToolFactory.createCodeFormatter(settings);
    TextEdit edit = formatter.format(
      CodeFormatter.K_COMPILATION_UNIT | CodeFormatter.F_INCLUDE_COMMENTS,
      source, 0, source.length(), 0, "\n");

    assertThat(edit)
      .as("Eclipse formatter returned null — the source file may not be valid Java")
      .isNotNull();

    Document document = new Document(source);
    edit.apply(document);
    return document.get();
  }

  private Map<String, String> loadProfileSettings() throws Exception
  {
    DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
    DocumentBuilder builder = factory.newDocumentBuilder();
    org.w3c.dom.Document doc = builder.parse(PROFILE_PATH.toFile());

    Map<String, String> settings = new HashMap<>();
    NodeList nodes = doc.getElementsByTagName("setting");
    for (int i = 0; i < nodes.getLength(); i++)
    {
      Element el = (Element) nodes.item(i);
      settings.put(el.getAttribute("id"), el.getAttribute("value"));
    }
    return settings;
  }
}
