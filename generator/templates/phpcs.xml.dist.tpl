<?xml version="1.0"?>
<ruleset name="{{PLUGIN_NAME}}">
  <description>PHPCS rules for {{PLUGIN_NAME}}</description>

  <!--
    Run this from the plugin root: `composer lint` / `composer lint-fix`.
    Invoking phpcs from another directory with a path argument silently skips
    this ruleset — you get the default PEAR standard and the exclude-patterns
    below are never applied, so vendor/ gets reformatted too.
  -->

  <file>.</file>

  <rule ref="WordPress-Core">
    <!--
      WPCS expects class-plugin.php for class Plugin. This scaffold instead
      prefixes every include with the plugin slug (class-{slug}-*.php) so
      files stay unambiguous when several plugins are open side by side.
      Deliberate convention — remove this exclude if you prefer WPCS default.
    -->
    <exclude name="WordPress.Files.FileName.InvalidClassFileName" />
  </rule>
  <rule ref="WordPress-Docs" />
  <rule ref="WordPress-Extra" />

  <exclude-pattern>*/vendor/*</exclude-pattern>
  <exclude-pattern>*/node_modules/*</exclude-pattern>
  <exclude-pattern>*/dist/*</exclude-pattern>
  <exclude-pattern>*/tests/*</exclude-pattern>

  <arg name="extensions" value="php,css"/>

  <config name="minimum_supported_wp_version" value="{{REQUIRES_WP}}" />
</ruleset>
