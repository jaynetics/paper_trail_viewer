require 'rails_helper'

describe PaperTrailViewer, versioning: true do
  let(:engine_urls) { PaperTrailViewer::Engine.routes.url_helpers }

  context 'without changes' do
    context 'when fetching the index' do
      it 'has no changes by default' do
        visit engine_urls.root_path

        expect(page).to have_content('No versions found')
      end
    end
  end

  context 'with changes' do
    let!(:reimu) { FactoryBot.create(:entity, name: 'Miko Hakurei Reimu', status: 'Highly Responsive to Prayers') }
    let!(:flanchan) { FactoryBot.create(:entity, name: 'Flandre Scarlet', status: 'The Embodiment of Scarlet Devil') }
    let!(:sakuya) { FactoryBot.create(:entity, name: 'Sakuya Izayoi', status: 'Flowering Night') }
    let!(:kyuu_hachi) { FactoryBot.create(:platform, name: 'PC-9801', status: 'SUGOI!!1!') }
    let!(:uinodouzu) { FactoryBot.create(:platform, name: 'Mikorusofto Uinodouzu', status: 'o-O') }

    before do
      reimu.update!(name: 'Hakurei Reimu', status: 'Phantasmagoria of Dimensional Dream')
      reimu.update!(status: 'Perfect Cherry Blossom')
      flanchan.destroy!
      kyuu_hachi.update!(status: 'Kimochi warui.')
      kyuu_hachi.destroy!
    end

    describe 'index' do
      before { visit engine_urls.root_path }

      it 'has all changes' do
        expect(page).to have_selector('[data-ci-type="version-row"]', count: 10)
      end

      it 'has changes for all changed item types' do
        within('table') do
          expect(page).to have_content('Entity')
          expect(page).to have_content('Platform')
        end
      end

      it 'orders changes with newest and highest id at the top' do
        ids = PaperTrail::Version.pluck(:id)
        expect(page).to have_content(/#{ids.sort.reverse.join('.+')}/m)
      end

      context 'when getting changes for a specific type' do
        before { visit engine_urls.root_path(item_type: 'Entity') }

        it 'shows a subset of the changes' do
          expect(page).to have_selector('[data-ci-type="version-row"]', count: 6)
        end
      end

      context 'when getting changes for a specific record' do
        before { visit engine_urls.root_path(item_type: 'Entity', item_id: reimu.id) }

        it 'shows a subset of the changes' do
          expect(page).to have_selector('[data-ci-type="version-row"]', count: 3)
        end
      end
    end

    describe 'tracking an item' do
      it 'works' do
        visit engine_urls.root_path
        expect(page).to have_selector('[data-ci-type="version-row"]', count: 10)

        open_reimu_actions_menu
        click_on 'Track item'

        expect(page).to have_selector('[data-ci-type="version-row"]', count: 3)
      end
    end

    describe 'rolling back changes' do
      it 'can be done via the UI' do
        visit engine_urls.root_path(item_type: 'Entity', item_id: reimu.id)

        open_reimu_actions_menu

        accept_confirm do # confirm that we really want to roll back
          accept_alert do # accept alert saying that rollback happened
            find('span', text: 'Roll back').click
          end
        end

        expect(Entity.exists?(reimu.id)).to eq false
      end

      it 'rolls back a newly-created record by deleting it' do
        expect(Entity).to exist(reimu.id)

        put engine_urls.version_path(reimu.versions.first)

        expect(Entity).not_to exist(reimu.id)
      end

      it 'rolls back an edit by reverting to the previous state' do
        reimu.reload
        expect(reimu.status).to eq 'Perfect Cherry Blossom'

        put engine_urls.version_path(reimu.versions.last)

        reimu.reload
        expect(reimu.status).to eq 'Phantasmagoria of Dimensional Dream'
      end

      it 'rolls back a delete by restoring the record' do
        expect(Entity.exists?(flanchan.id)).to eq false

        version = PaperTrail::Version.where(item_id: flanchan.id, item_type: 'Entity').last
        put engine_urls.version_path(version)

        found = Entity.find(flanchan.id)
        expect(found.status).to eq 'The Embodiment of Scarlet Devil'
      end
    end
  end

  def open_reimu_actions_menu
    within("tr[data-ci-id='#{reimu.versions.find_by!(event: :create).id}']") do
      find('[data-ci-type="version-action-button"]').click
    end
  end
end
