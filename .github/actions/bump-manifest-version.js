const fs = require('fs').promises; // Using promises version for cleaner async code

// Main function to update the version in fxmanifest.lua
async function updateManifestVersion() {
  try {
    // Get the version from environment variable and remove 'v' prefix if present
    const rawVersion = process.env.N_RELEASE_V;
    if (!rawVersion) {
      throw new Error('N_RELEASE_V not provided in environment variables');
    }
    const version = rawVersion.startsWith('v') ? rawVersion.slice(1) : rawVersion;

    // Read the content of fxmanifest.lua
    const manifestPath = 'fxmanifest.lua';
    const originalContent = await fs.readFile(manifestPath, { encoding: 'utf8' });

    // Replace the version line with the new value
    const updatedContent = originalContent.replace(
      /\bversion\s+['"][^'"]*['"]/i, // Matches 'version "x.y.z"' or 'version 'x.y.z''
      `version '${version}'`
    );

    // Check if there were changes (avoid unnecessary writes)
    if (updatedContent === originalContent) {
      console.log('No version line found to update or it already has the correct version');
      return;
    }

    // Write the updated content back to the file
    await fs.writeFile(manifestPath, updatedContent, { encoding: 'utf8' });
    console.log(`Version in ${manifestPath} updated to ${version} successfully`);

  } catch (error) {
    console.error('Error updating fxmanifest.lua:', error.message);
    process.exit(1); // Exit with error code to fail the workflow if something goes wrong
  }
}

// Run the function
updateManifestVersion();
